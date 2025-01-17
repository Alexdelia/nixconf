{pkgs, ...}: let
  coreutils = pkgs.uutils-coreutils-noprefix;

  echo = "${coreutils}/bin/echo";
  docker = "docker";
in
  pkgs.writers.writeBashBin
  "drm" {}
  /*
  bash
  */
  ''
    HELP="usage: \033[1m$0 \033[35m<type1> <type2> ...\033[0m\ntype:\n\t\033[1ms\033[0m, \033[1mstop\033[0m\t\033[1;34mstop\033[0m all containers\n\t\033[1mc\033[0m, \033[1mcontainer\033[0m\t\033[1;33mprune\033[0m all containers\n\t\033[1mi\033[0m, \033[1mimage\033[0m\t\033[1;33mprune\033[0m all images\n\t\033[1mv\033[0m, \033[1mvolume\033[0m\t\033[1;33mprune\033[0m all volumes\n\t\033[1mn\033[0m, \033[1mnetwork\033[0m\t\033[1;33mprune\033[0m all networks\n\t\033[1ma\033[0m, \033[1mall\033[0m, \033[1my\033[0m, \033[1myes\033[0m\t\033[1;31mremove\033[0m all containers, images, volumes and networks\n\t\033[1mp\033[0m, \033[1mprune\033[0m\t\033[1;33mprune\033[0m all containers, images, volumes and networks"

    if [[ $# -lt 1 ]]; then
    	${echo} -e $HELP
    	exit 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
    fi

    for t in "$@"; do
    	case "$t" in
    	"s" | "stop")
    		${docker} stop $(${docker} ps -qa)
    		;;
    	"c" | "container")
    		${docker} container prune -f
    		;;
    	"i" | "image")
    		${docker} image prune -af
    		;;
    	"v" | "volume")
    		${docker} volume prune -af
    		;;
    	"n" | "network")
    		${docker} network prune -f
    		;;
    	"a" | "all" | "y" | "yes")
    		${docker} stop $(${docker} ps -qa)
    		${docker} system prune -af --volumes
    		${docker} volume prune -af
    		;;
    	"p" | "prune")
    		${docker} system prune -af --volumes
    		${docker} volume prune -af
    		;;
    	*)
    		${echo} -e "unknown type:\t\033[1;33m$t\033[0m"
    		${echo} -e $HELP
    		exit 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
    		;;
    	esac
    done
  ''
