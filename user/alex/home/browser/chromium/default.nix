{pkgs, ...}: let
  package = pkgs.brave;
in {
  imports = [
    ./extension
  ];

  programs.chromium = {
    enable = true;

    inherit package;

    commandLineArgs = [
      "--ozone-platform-hint=auto"

      "--disable-features=GlobalShortcutsPortal"
    ];
  };
}
