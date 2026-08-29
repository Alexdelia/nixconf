{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "gdl";
  runtimeInputs = with pkgs; [ git ];
  text = ''
    git show "HEAD~''${1:-0}"
  '';
}
