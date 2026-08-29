{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "xo";
  runtimeInputs = with pkgs; [ xdg-utils ];
  text = ''
    for file in "$@"; do
    	xdg-open "$file" &
    done
  '';
}
