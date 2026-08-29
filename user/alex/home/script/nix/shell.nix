{ pkgs }:
{
  name,
  unstable ? false,
  unfree ? false,
  argRequired ? true,
}:
let
  inherit (pkgs) lib;

  registry = if unstable then "github:NixOS/nixpkgs/nixpkgs-unstable" else "nixpkgs";
  impure = lib.optionalString unfree " --impure";

  empty =
    if argRequired then
      ''
        printf 'usage: \033[1m%s \033[35m<pkg1> <pkg2> ...\033[0m\n' "$0"
        exit 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
      ''
    else
      "exec nom shell${impure}";
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [ nix-output-monitor ];
  text = lib.optionalString unfree "export NIXPKGS_ALLOW_UNFREE=1\n\n" + ''
    if [[ $# -eq 0 ]]; then
    	${empty}
    fi

    ref=()
    for pkg in "$@"; do
    	ref+=("${registry}#$pkg")
    done

    nom shell${impure} "''${ref[@]}"
  '';
}
