{ pkgs, ... }:
let
  package = pkgs.brave;
in
{
  imports = [
    ./extension

    ./local-extension.nix
    ./material-icons.nix
    ./no-leave-prompt.nix
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
