{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "baj";
  runtimeInputs = with pkgs; [
    bat
    jaq
  ];
  text = ''
    if [[ $# -lt 1 ]]; then
    	jaq | bat -p -l=json
    	exit
    fi

    jaq . "$1" | bat -p -l=json
  '';
}
