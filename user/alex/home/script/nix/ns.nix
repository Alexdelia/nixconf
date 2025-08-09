{pkgs, ...}: let
  nom = "${pkgs.nix-output-monitor}/bin/nom";
in
  pkgs.writers.writeBashBin
  "ns" {}
  /*
  bash
  */
  ''
    if [[ $# -eq 0 ]]; then
    	${nom} shell
    fi

    pkgs=""
    for pkg in "$@"; do
    	pkgs+="nixpkgs#$pkg "
    done

    ${nom} shell $pkgs
  ''
