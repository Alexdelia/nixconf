{
  config,
  pkgs,
  lib,
  ...
}:
let
  slackTo = "move container to workspace communication, workspace communication";

  bravePlace = pkgs.writeShellApplication {
    name = "sway-brave-place";
    runtimeInputs = with pkgs; [
      sway
      jaq
    ];
    text = ''
      # on/off written by hdmi-watch (hdmi.nix); absent -> treat TV as off
      state="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hdmi-state"

      hdmi_on() {
        local s
        read -r s <"$state" 2>/dev/null || return 1
        [ "$s" = on ]
      }

      place() {
        local id="$1"
        local follow="$2"
        local ws
        if hdmi_on; then ws=media; else ws=browser; fi
        swaymsg "[con_id=$id] move container to workspace \"$ws\"" >/dev/null
        if [ "$follow" = 1 ]; then swaymsg workspace "$ws" >/dev/null; fi
      }

      brave_id() {
        swaymsg -t get_tree | jaq -r 'first(recurse(.nodes[]?, .floating_nodes[]?)
          | select(.app_id == "brave-browser" or (.window_properties.class? == "brave-browser"))
          | .id) // empty'
      }

      swaymsg -t subscribe -m '["window", "output"]' | while read -r ev; do
        if [ "$(jaq -r 'has("container")' <<<"$ev")" = true ]; then
          [ "$(jaq -r '.change' <<<"$ev")" = new ] || continue
          appid="$(jaq -r '.container.app_id // empty' <<<"$ev")"
          class="$(jaq -r '.container.window_properties.class // empty' <<<"$ev")"
          if [ "$appid" = brave-browser ] || [ "$class" = brave-browser ]; then
            place "$(jaq -r '.container.id' <<<"$ev")" 1
          fi
        else
          id="$(brave_id)"
          if [ -n "$id" ]; then place "$id" 0; fi
        fi
      done
    '';
  };
in
{
  config = lib.mkIf config.wayland.windowManager.sway.enable {
    wayland.windowManager.sway.config.window.commands = [
      {
        criteria.app_id = "Slack";
        command = slackTo;
      }
      {
        criteria.class = "Slack";
        command = slackTo;
      }
    ];

    systemd.user.services.sway-brave-place = {
      Unit = {
        Description = "HDMI brave window placement for sway";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${bravePlace}/bin/sway-brave-place";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
