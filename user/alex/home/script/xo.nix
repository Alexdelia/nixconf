{ pkgs, ... }:
let
  xdg-open = "${pkgs.xdg-utils}/bin/xdg-open";
in
pkgs.writers.writeBashBin "xo" { } /* bash */ ''
  for file in "$@"; do
  	${xdg-open} "$file" &
  done
''
