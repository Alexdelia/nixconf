{pkgs, ...}: let
  coreutils = pkgs.uutils-coreutils-noprefix;

  echo = "${coreutils}/bin/echo";
  lsof = "${pkgs.lsof}/bin/lsof";
in
  pkgs.writers.writeBashBin
  "kill-on-port" {}
  /*
  bash
  */
  ''
    if [[ $# -lt 1 ]]; then
    	${echo} -e "usage: \033[1m$0 \033[35m<port>\033[0m"
    	exit 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
    fi

    PORT="$1"
    ${lsof} -i:"$PORT" -sTCP:LISTEN -t | xargs -r kill
  ''
