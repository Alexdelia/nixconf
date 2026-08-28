{
  pkgs,
  rmpc,
  clipboardCopy,
}:
pkgs.writeShellApplication {
  name = "rmpc-copy-uuid";
  runtimeInputs = with pkgs; [
    rmpc
    jaq
    libnotify
  ];
  text = ''
    arg=()
    if [ "''${1:-selected}" = selected ]; then
      while IFS= read -r path; do
        [ -n "$path" ] || continue
        arg+=(-p "$path")
      done <<< "''${SELECTED_SONGS:-}"
    fi

    if ! song=$(rmpc song "''${arg[@]}"); then
      notify-send -u critical "rmpc" "no song"
      exit 1
    fi

    uuid=$(jaq -r '[.] | flatten | .[].metadata.musicbrainz_trackid // empty' <<< "$song")

    if [ -z "$uuid" ]; then
      notify-send -u critical "rmpc" "no musicbrainz_trackid"
      exit 1
    fi

    ${clipboardCopy} "$uuid"
    notify-send "uuid copied" "$uuid"
  '';
}
