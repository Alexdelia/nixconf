{
  pkgs,
  dubbed ? false,
  ...
}: let
  ani-cli = "${pkgs.ani-cli}/bin/ani-cli";
  bin =
    if !dubbed
    then ani-cli
    else "${ani-cli} --dub";
in
  pkgs.writers.writeBashBin
  (
    if !dubbed
    then "ani"
    else "anib"
  ) {}
  /*
  bash
  */
  ''
    if [[ $# -eq 0 ]]; then
    	${bin} --continue
    	exit $?
    fi

    ${bin} "$@"
  ''
