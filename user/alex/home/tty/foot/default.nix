{
  lib,
  config,
  scheme ? { },
  ...
}:
let
  fontFamily = "SauceCodeProNerdFont";
  fontSize = 16;
in
{
  programs.foot = {
    enable = true;

    settings = lib.recursiveUpdate {
      main = {
        # term = "foot";
        # term = "xterm-256color";

        font = "${fontFamily}:style=Regular:size=${toString fontSize}";
        font-bold = "${fontFamily}:style=Black:size=${toString fontSize}";

        initial-window-mode = "maximized";
        initial-window-size-chars = "128x32";
      };

      colors-dark.alpha = 1.0;

      csd.preferred = "none";
    } (import ./scheme.nix { scheme = config.scheme or scheme; });
  };

  stylix.targets.foot.enable = false;
}
