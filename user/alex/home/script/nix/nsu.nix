{pkgs, ...}: let
  nom = "${pkgs.nix-output-monitor}/bin/nom";
in
  pkgs.writers.writeBashBin
  "nsu" {}
  /*
  bash
  */
  ''
    if [[ $# -eq 0 ]]; then
    	printf "usage: \033[1m$0 \033[35m<pkg1> <pkg2> ...\033[0m\n"
    	exit 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
    fi

    pkgs=""
    for pkg in "$@"; do
    	pkgs+="nixpkgs#$pkg "
    done

    NIXPKGS_ALLOW_UNFREE=1 ${nom} shell --impure $pkgs
  ''
