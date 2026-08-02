{
  pkgs,
  lib,
  config,
  scheme ? { },
  ...
}:
{
  terminal = {
    command = "${pkgs.alacritty-graphics}/bin/alacritty";
    exec =
      {
        command,
        fontSize ? null,
      }:
      config.terminal.command
      + lib.optionalString (fontSize != null) " -o font.size=${toString fontSize}"
      + " -e ${command}";
  };

  programs = {
    alacritty = {
      enable = true;

      package = pkgs.alacritty-graphics;

      settings = {
        env = {
          TERM = "xterm-256color";
        };

        general.live_config_reload = false;

        font = {
          size = 16.0;

          normal = {
            family = "SauceCodeProNerdFont";
            style = "Regular";
          };
          bold = {
            family = "SauceCodeProNerdFont";
            style = "Black";
          };
        };

        window = {
          opacity = 1.0;

          decorations = "None";
          startup_mode = "Maximized";

          dimensions = {
            columns = 128;
            lines = 32;
          };
        };
      }
      // (import ./scheme.nix {
        scheme = config.scheme or scheme;
      });
    };
  };

  stylix.targets.alacritty.enable = false;
}
