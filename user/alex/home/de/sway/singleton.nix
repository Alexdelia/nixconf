{
  config,
  pkgs,
  lib,
  ...
}: let
  media = lib.attrNames (lib.filterAttrs (_: m: m.media) config.hostOption.spec.monitor);
  mediaOutput =
    if media == []
    then ""
    else lib.head media;

  slackTo = "move container to workspace communication, workspace communication";

  bravePlace = pkgs.writeShellApplication {
    name = "sway-brave-place";
    runtimeInputs = [pkgs.sway pkgs.jq];
    text = ''
      media=${lib.escapeShellArg mediaOutput}

      hdmi_on() {
        [ -n "$media" ] || return 1
        swaymsg -t get_outputs | jq -e --arg o "$media" 'any(.[]; .name == $o and .active)' >/dev/null
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
        swaymsg -t get_tree | jq -r 'first(recurse(.nodes[]?, .floating_nodes[]?)
          | select(.app_id == "brave-browser" or (.window_properties.class? == "brave-browser"))
          | .id) // empty'
      }

      swaymsg -t subscribe -m '["window", "output"]' | while read -r ev; do
        if [ "$(jq -r 'has("container")' <<<"$ev")" = true ]; then
          [ "$(jq -r '.change' <<<"$ev")" = new ] || continue
          appid="$(jq -r '.container.app_id // empty' <<<"$ev")"
          class="$(jq -r '.container.window_properties.class // empty' <<<"$ev")"
          if [ "$appid" = brave-browser ] || [ "$class" = brave-browser ]; then
            place "$(jq -r '.container.id' <<<"$ev")" 1
          fi
        else
          id="$(brave_id)"
          if [ -n "$id" ]; then place "$id" 0; fi
        fi
      done
    '';
  };
in {
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
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${bravePlace}/bin/sway-brave-place";
        Restart = "on-failure";
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
