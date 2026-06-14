{pkgs}: {
  name,
  unstable ? false,
  unfree ? false,
  argRequired ? true,
}: let
  nom = "${pkgs.nix-output-monitor}/bin/nom";
  registry =
    if unstable
    then "github:NixOS/nixpkgs/nixpkgs-unstable"
    else "nixpkgs";
  shell =
    if unfree
    then "NIXPKGS_ALLOW_UNFREE=1 ${nom} shell --impure"
    else "${nom} shell";
  empty =
    if argRequired
    then
      /*
      bash
      */
      ''
        printf "usage: \033[1m$0 \033[35m<pkg1> <pkg2> ...\033[0m\n"
        exit 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
      ''
    else shell;
in
  pkgs.writers.writeBashBin
  name {}
  /*
  bash
  */
  ''
    if [[ $# -eq 0 ]]; then
    	${empty}
    fi

    pkgs=""
    for pkg in "$@"; do
    	pkgs+="${registry}#$pkg "
    done

    ${shell} $pkgs
  ''
