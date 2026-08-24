{
  config,
  pkgs,
  lib,
  ...
}:
let
  mediaEnabled = lib.filterAttrs (_: m: m.media) config.hostOption.spec.monitor != { };

  hostFile = config.sops.secrets."jiruo/hdmi-host".path;

  sink = import ./sink.nix;
  switchSink = import ./switch-sink.nix { inherit pkgs; };

  armShutdown = true;

  hdmiWatch = pkgs.writeShellApplication {
    name = "hdmi-watch";
    runtimeInputs = with pkgs; [
      curl
      jaq
      sway
      switchSink
      uutils-coreutils-noprefix
      libnotify
      speechd
    ];
    excludeShellChecks = [ "SC2016" ];
    text = ''
      arm=${if armShutdown then "1" else "0"}

      state="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hdmi-state"
      grace="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hdmi-grace"

      interval_on=1
      need_on=1

      interval_off=4
      need_off=2

      acquire_max=44

      grace_active() {
        local until
        until="$(cat "$grace" 2>/dev/null)" || return 1
        [ -n "$until" ] && [ "$(date +%s)" -lt "$until" ]
      }

      probe() {
        grace_active && return 0
        local host out
        host="$(cat ${lib.escapeShellArg hostFile} 2>/dev/null)"
        [ -n "$host" ] || return 1
        out="$(curl -sf --max-time 1.5 "http://$host:7676/smp_4_" \
          -H 'Content-Type: text/xml; charset="utf-8"' \
          -H 'SOAPACTION: "urn:samsung.com:service:MainTVAgent2:1#GetCurrentExternalSource"' \
          -d '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetCurrentExternalSource xmlns:u="urn:samsung.com:service:MainTVAgent2:1"></u:GetCurrentExternalSource></s:Body></s:Envelope>')" || return 1
        [[ "$out" == *"<CurrentExternalSource>"* ]]
      }

      move_ws() {
        local from="$1" to="$2" follow="$3" ids id
        mapfile -t ids < <(swaymsg -t get_tree | jaq -r --arg ws "$from" '
          recurse(.nodes[]?, .floating_nodes[]?)
          | select(.type == "workspace" and .name == $ws)
          | recurse(.nodes[]?, .floating_nodes[]?)
          | select((.type == "con" or .type == "floating_con") and (.nodes | length) == 0)
          | .id')
        for id in "''${ids[@]}"; do
          swaymsg "[con_id=$id] move container to workspace \"$to\"" >/dev/null
        done
        if [ "$follow" = 1 ]; then swaymsg workspace "$to" >/dev/null; fi
      }

      window_count() {
        swaymsg -t get_tree | jaq '[recurse(.nodes[]?, .floating_nodes[]?)
          | select((.type == "con" or .type == "floating_con") and (.nodes | length) == 0)] | length'
      }

      brave_quit() {
        local pid
        pid="$(swaymsg -t get_tree | jaq -r 'first(recurse(.nodes[]?, .floating_nodes[]?)
          | select(.app_id == "brave-browser" or (.window_properties.class? == "brave-browser"))
          | .pid) // empty')"
        [ -n "$pid" ] && kill -TERM "$pid" 2>/dev/null || true
      }

      shutdown_prompt() {
        local t baseline
        ${config.customScript.isMediaDefaultTime} || return 0

        baseline="$(window_count)"

        notify-send -u critical "shutdown" "shutting down in 60 seconds"
        spd-say "Shutting down in 60 seconds." || true

        for ((t = 0; t < 60; t++)); do
          sleep 1
          if [ "$(cat "$state" 2>/dev/null)" = on ]; then
            notify-send "shutdown" "cancelled"
            return 0
          fi
          if [ "$(window_count)" -gt "$baseline" ]; then
            notify-send "shutdown" "cancelled"
            return 0
          fi
        done

        brave_quit
        if [ "$arm" = 1 ]; then
          systemctl poweroff
        else
          notify-send -u critical "shutdown" "dry-run"
        fi
      }

      on_hdmi() {
        move_ws browser media 1
        switch-sink ${lib.escapeShellArg sink.hdmi}
      }

      off_hdmi() {
        move_ws media browser 0
        switch-sink ${lib.escapeShellArg sink.analog}
        shutdown_prompt &
      }

      watch_session() {
        local hits=0 misses=0 waited=0 iv
        while :; do
          if probe; then
            hits=$((hits + 1))
            misses=0
            if [ "$cur" != on ] && [ "$hits" -ge "$need_on" ]; then
              cur=on
              printf 'on\n' >"$state"
              on_hdmi
            fi
          else
            misses=$((misses + 1))
            hits=0
            if [ "$cur" = on ] && [ "$misses" -ge "$need_off" ]; then
              cur=off
              printf 'off\n' >"$state"
              off_hdmi
              return 0
            fi
          fi

          if [ "$cur" = on ]; then
            iv="$interval_off"
          else
            iv="$interval_on"
            waited=$((waited + iv))
            [ "$waited" -ge "$acquire_max" ] && return 0
          fi
          sleep "$iv"
        done
      }

      if grace_active; then
        cur=on
        printf 'on\n' >"$state"
        watch_session
      else
        printf 'off\n' >"$state"
        cur=off
      fi

      swaymsg -t subscribe -m '["output"]' | while read -r _; do
        watch_session
        while read -r -t 0.1 _; do :; done
      done
    '';
  };
in
{
  config = lib.mkIf (config.wayland.windowManager.sway.enable && mediaEnabled) {
    systemd.user.services.hdmi-watch = {
      Unit = {
        Description = "track HDMI media screen power, drive sound & workspace + work-hours shutdown";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${hdmiWatch}/bin/hdmi-watch";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
