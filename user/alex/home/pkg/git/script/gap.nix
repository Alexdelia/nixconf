{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "gap";
  runtimeInputs = with pkgs; [ git ];
  text = ''
    if [[ $# -eq 0 ]]; then
    	git add --intent-to-add .
    else
    	git add --intent-to-add "$@"
    fi

    git add -p "$@"
    git status --short

    printf "\n\033[3mun-add:\033[0m\t\033[1;38;2;232;77;49mgit\033[39m restore \033[2m--staged\033[0m \033[1;35m<path>\033[0m\n\033[3m    or:\033[0m\t\033[1;38;2;232;77;49mg\033[39mr\033[2ms \033[35m[path]\033[0m\n"
  '';
}
