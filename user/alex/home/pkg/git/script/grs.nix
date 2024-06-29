{pkgs, ...}: (
  pkgs.writers.writeBashBin
  "grs" {}
  /*
  bash
  */
  ''
    if [[ $# -eq 0 ]]; then
    	git restore --staged .
    else
    	git restore --staged "$@"
    fi
    git status --short
  ''
)
