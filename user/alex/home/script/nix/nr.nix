{pkgs, ...}: (
  pkgs.writers.writeBashBin
  "nr" {}
  /*
  bash
  */
  ''
    if [[ $# -ne 1 ]]; then
      printf "usage: \033[1m$0 \033[35m<pkg>\033[0m\n"
      exit 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
    fi

    nix run nixpkgs#$1
  ''
)
