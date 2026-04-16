{pkgs, ...}: let
  bat = "${pkgs.bat}/bin/bat";
  jq = "${pkgs.jaq}/bin/jaq";
in
  pkgs.writers.writeBashBin
  "baj" {}
  /*
  bash
  */
  ''
    if [[ $# -lt 1 ]]; then
    	${jq} | ${bat} -p -l=json
    	exit
    fi

    ${jq} . "$1" | ${bat} -p -l=json
  ''
