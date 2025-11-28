{pkgs, ...}: (
  pkgs.writers.writeBashBin
  "gdl" {}
  /*
  bash
  */
  ''
    if [ "$#" -eq 0 ]; then
    	git show 'HEAD'
    else
    	git show "HEAD~$1"
    fi
  ''
)
