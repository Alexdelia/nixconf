{
  config,
  pkgs,
  lib,
  ...
}: let
  mediaEnabled = lib.filterAttrs (_: m: m.media) config.hostOption.spec.monitor != {};

  sink = import ./sink.nix;

  graceTimeSec = 300;

  mediaBoot = pkgs.writeShellApplication {
    name = "media-boot";
    runtimeInputs = with pkgs; [
      sway
      pulseaudio
      systemd
      uutils-coreutils-noprefix
    ];
    text = ''
      ${config.customScript.isMediaDefaultTime} || exit 0
      ${config.dp.mediaBootPrompt} || exit 0

      state="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hdmi-state"
      grace="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hdmi-grace"
      printf 'on\n' >"$state"
      echo "$(($(date +%s) + ${toString graceTimeSec}))" >"$grace"

      pactl set-default-sink ${lib.escapeShellArg sink.hdmi} || true
      pactl list short sink-inputs | while read -r i _; do
        pactl move-sink-input "$i" ${lib.escapeShellArg sink.hdmi} 2>/dev/null || true
      done

      swaymsg workspace media
      swaymsg exec '${config.dp.browser} --profile-directory="Profile 2"'

      systemctl --user restart hdmi-watch
    '';
  };
in {
  config = lib.mkIf (config.wayland.windowManager.sway.enable && mediaEnabled) {
    systemd.user.services.media-boot = {
      Unit = {
        Description = "login prompt to use the TV, then switch sound to HDMI + open browser on media";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${mediaBoot}/bin/media-boot";
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
