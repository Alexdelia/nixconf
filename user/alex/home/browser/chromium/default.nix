{ pkgs, ... }:
let
  package = pkgs.brave;
in
{
  imports = [
    ./extension
  ];

  programs.chromium = {
    enable = true;

    inherit package;

    commandLineArgs = [
      "--ozone-platform-hint=auto"

      "--accept-lang=en-GB,en,fr"

      "--disable-features=GlobalShortcutsPortal"
    ];
  };
}
