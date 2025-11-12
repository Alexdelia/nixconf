{pkgs, ...}: (
  pkgs.writers.writeBashBin
  "gdl" {}
  /*
  bash
  */
  ''
    git diff "HEAD~''${1:-1}"
  ''
)
