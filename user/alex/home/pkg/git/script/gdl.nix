{pkgs, ...}: (
  pkgs.writers.writeBashBin
  "gdl" {}
  /*
  bash
  */
  ''
    git show "HEAD~''${1:-0}"
  ''
)
