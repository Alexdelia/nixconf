{
  config,
  pkgs,
  lib,
  ...
}:
let
  mediaEnabled = lib.filterAttrs (_: m: m.media) config.hostOption.spec.monitor != { };

  sink = import ./sink.nix;
  switchSink = import ./switch-sink.nix { inherit pkgs; };

  graceTimeSec = 300;

  mediaBoot = pkgs.writeShellApplication {
    name = "media-boot";
    runtimeInputs = with pkgs; [
      sway
      switchSink
      systemd
      uutils-coreutils-noprefix
      gnome-keyring
    ];
    text = ''
      ${config.customScript.isMediaDefaultTime} || exit 0

      password="$(${config.dp.mediaBootPrompt})" || exit 0

      state="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hdmi-state"
      grace="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hdmi-grace"
      printf 'on\n' >"$state"
      echo "$(($(date +%s) + ${toString graceTimeSec}))" >"$grace"

      switch-sink ${lib.escapeShellArg sink.hdmi} &

      swaymsg workspace media

      if [ -n "$password" ]; then
        printf '%s' "$password" | gnome-keyring-daemon --unlock >/dev/null 2>&1 || true
      fi
      unset password

      swaymsg exec '${config.dp.browser} --password-store=gnome-libsecret --profile-directory="Profile 2"'

      systemctl --user restart hdmi-watch
    '';
  };
in
{
  config = lib.mkIf (config.wayland.windowManager.sway.enable && mediaEnabled) {
    wayland.windowManager.sway.config.startup = [
      { command = "${mediaBoot}/bin/media-boot"; }
    ];
  };
}
