{pkgs, ...}: (
  pkgs.writers.writeBashBin
  "ns" {}
  /*
  bash
  */
  ''
    if [[ $# -eq 0 ]]; then
    	nix shell
    fi

    pkgs=""
    for pkg in "$@"; do
    	pkgs+="nixpkgs#$pkg "
    done

    nix shell $pkgs
  ''
)
