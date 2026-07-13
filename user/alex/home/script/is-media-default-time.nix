{pkgs}: let
  forceIsMediaDefaultTime = false;
in
  pkgs.writeShellApplication {
    name = "is-media-default-time";
    runtimeInputs = with pkgs; [uutils-coreutils-noprefix];
    text =
      if forceIsMediaDefaultTime
      then "exit 0"
      else ''
        d="$(date +%u)"
        h=$((10#$(date +%H)))
        [ "$d" -ge 1 ] && [ "$d" -le 5 ] && [ "$h" -lt 17 ]
      '';
  }
