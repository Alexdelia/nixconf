{pkgs}:
pkgs.writeShellApplication {
  name = "is-media-default-time";
  runtimeInputs = with pkgs; [uutils-coreutils-noprefix];
  text = ''
    d="$(date +%u)"
    h=$((10#$(date +%H)))
    [ "$d" -ge 1 ] && [ "$d" -le 5 ] && [ "$h" -lt 17 ]
  '';
}
