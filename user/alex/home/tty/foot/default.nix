{
  pkgs,
  lib,
  config,
  scheme ? { },
  ...
}:
let
  fontFamily = "SauceCodeProNerdFont";
  defaultFontSize = 16;

  font = style: size: "${fontFamily}:style=${style}:size=${toString size}";
in
{
  terminal = {
    command = "${pkgs.foot}/bin/foot";
    exec =
      {
        command,
        fontSize ? null,
      }:
      config.terminal.command
      + lib.optionalString (
        fontSize != null
      ) " -o main.font=${font "Regular" fontSize} -o main.font-bold=${font "Black" fontSize}"
      + " ${command}";
  };

  programs.foot = {
    enable = true;

    settings = lib.recursiveUpdate {
      main = {
        # term = "foot";
        # term = "xterm-256color";

        font = font "Regular" defaultFontSize;
        font-bold = font "Black" defaultFontSize;

        initial-window-mode = "maximized";
        initial-window-size-chars = "128x32";
      };

      colors-dark.alpha = 1.0;

      csd.preferred = "none";
    } (import ./scheme.nix { scheme = config.scheme or scheme; });
  };

  stylix.targets.foot.enable = false;
}
