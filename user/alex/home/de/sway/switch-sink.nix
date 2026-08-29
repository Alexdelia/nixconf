{ pkgs }:
pkgs.writeShellApplication {
  name = "switch-sink";
  runtimeInputs = with pkgs; [
    pulseaudio
    uutils-coreutils-noprefix
  ];
  text = ''
    sink="$1"

    # sink shows up only once the card is (re)plugged, can lag the sway output event
    appear_max=20

    for ((t = 0; t < appear_max; t++)); do
    	pactl set-default-sink "$sink" 2>/dev/null && break
    	sleep 1
    done

    pactl list short sink-inputs 2>/dev/null | while read -r i _; do
    	pactl move-sink-input "$i" "$sink" 2>/dev/null || true
    done || true
  '';
}
