{pkgs}: let
  forceIsMediaDefaultTime = false;
in
  pkgs.writeShellApplication {
    name = "is-media-default-time";
    runtimeInputs = with pkgs; [uutils-coreutils-noprefix];
    text = ''
      ${pkgs.lib.optionalString forceIsMediaDefaultTime "exit 0"}
      d="$(date +%u)"
      h=$((10#$(date +%H)))
      [ "$d" -ge 1 ] && [ "$d" -le 5 ] && [ "$h" -lt 17 ]
    '';
  }
