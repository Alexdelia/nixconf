{ pkgs, ... }:
let
  package = pkgs.brave;
in
{
  imports = [
    ./extension

    ./self-hosted-forgejo.nix
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
