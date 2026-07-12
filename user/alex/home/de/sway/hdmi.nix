{
  config,
  pkgs,
  lib,
  ...
}: let
  mediaEnabled = lib.filterAttrs (_: m: m.media) config.hostOption.spec.monitor != {};

  hostFile = config.sops.secrets."jiruo/hdmi-host".path;

  hdmiSink = "alsa_output.pci-0000_01_00.1.hdmi-stereo";
  analogSink = "alsa_output.pci-0000_00_1f.3.analog-stereo";

  armShutdown = false;

  hdmiWatch = pkgs.writeShellApplication {
    name = "hdmi-watch";
    runtimeInputs = with pkgs; [
      curl
      jaq
      sway
      uutils-coreutils-noprefix
      pulseaudio
      libnotify
      speechd
    ];
    excludeShellChecks = ["SC2016"];
    text = ''
      state="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hdmi-state"
      arm=${
        if armShutdown
        then "1"
        else "0"
      }

      interval_on=1
      need_on=1

      interval_off=4
      need_off=2

      acquire_max=44

      probe() {
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

      switch_sink() {
        local sink="$1" i
        pactl set-default-sink "$sink" || true
        pactl list short sink-inputs 2>/dev/null | while read -r i _; do
          pactl move-sink-input "$i" "$sink" 2>/dev/null || true
        done || true
      }

      brave_quit() {
        local pid
        pid="$(swaymsg -t get_tree | jaq -r 'first(recurse(.nodes[]?, .floating_nodes[]?)
          | select(.app_id == "brave-browser" or (.window_properties.class? == "brave-browser"))
          | .pid) // empty')"
        [ -n "$pid" ] && kill -TERM "$pid" 2>/dev/null || true
      }

      shutdown_prompt() {
        local d h t
        d="$(date +%u)"
        h=$((10#$(date +%H)))
        [ "$d" -ge 1 ] && [ "$d" -le 5 ] && [ "$h" -lt 17 ] || return 0

        notify-send -u critical "Shutdown" "Shutting down in 60 seconds. Turn the TV back on to cancel."
        spd-say "Shutting down in 60 seconds. Turn the television back on to cancel." || true

        for ((t = 0; t < 60; t++)); do
          sleep 1
          if [ "$(cat "$state" 2>/dev/null)" = on ]; then
            notify-send "Shutdown" "Cancelled — TV back on."
            return 0
          fi
        done

        brave_quit
        if [ "$arm" = 1 ]; then
          systemctl poweroff
        else
          notify-send -u critical "Shutdown (dry-run)" "armShutdown off — would power off now."
        fi
      }

      on_hdmi() {
        switch_sink ${lib.escapeShellArg hdmiSink}
        move_ws browser media 1
      }

      off_hdmi() {
        switch_sink ${lib.escapeShellArg analogSink}
        move_ws media browser 0
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

      printf 'off\n' >"$state"
      cur=off

      swaymsg -t subscribe -m '["output"]' | while read -r _; do
        watch_session
        while read -r -t 0.1 _; do :; done
      done
    '';
  };
in {
  config = lib.mkIf (config.wayland.windowManager.sway.enable && mediaEnabled) {
    systemd.user.services.hdmi-watch = {
      Unit = {
        Description = "track HDMI media screen power, drive sound & workspace + work-hours shutdown";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${hdmiWatch}/bin/hdmi-watch";
        Restart = "on-failure";
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
