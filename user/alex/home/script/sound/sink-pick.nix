{
  config,
  pkgs,
  switchSink,
}:
pkgs.writeShellApplication {
  name = "sink-pick";
  runtimeInputs = with pkgs; [
    jaq
    pulseaudio
    switchSink
  ];
  text = ''
    current="$(pactl get-default-sink)"

    entry=()
    declare -A sink

    while IFS=$'\t' read -r name description; do
    	if [ "$name" = "$current" ]; then
    		label="* $description"
    	else
    		label="  $description"
    	fi
    	entry+=("$label")
    	sink["$label"]="$name"
    done < <(pactl -f json list sinks | jaq -r '.[] | "\(.name)\t\(.description)"')

    chosen="$(printf '%s\n' "''${entry[@]}" | ${config.dp.picker})"
    [ -n "$chosen" ] || exit 0

    switch-sink "''${sink["$chosen"]}"
  '';
}
