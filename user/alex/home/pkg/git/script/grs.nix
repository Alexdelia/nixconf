{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "grs";
  runtimeInputs = with pkgs; [ git ];
  text = ''
    if [[ $# -eq 0 ]]; then
    	git restore --staged .
    else
    	git restore --staged "$@"
    fi

    git status --short
  '';
}
