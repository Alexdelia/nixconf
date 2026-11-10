{ config, pkgs, ... }:
let
  package = pkgs.brave-origin;
in
{
  imports = [
    ./extension

    ./local-extension.nix
    ./material-icons.nix
    ./no-leave-prompt.nix
  ];

  programs.brave = {
    enable = true;

    inherit package;

    commandLineArgs = [
      # brave-origin defaults to BraveSoftware/Brave-Origin; reuse the brave profile, also where hm writes brave extensions
      "--user-data-dir=${config.xdg.configHome}/BraveSoftware/Brave-Browser"

      "--ozone-platform-hint=auto"

      "--accept-lang=en-GB,en,fr"

      "--disable-features=GlobalShortcutsPortal"
    ];
  };
}
