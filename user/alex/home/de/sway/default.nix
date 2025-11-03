{
  config,
  pkgs,
  lib,
  ...
}: let
  checkConfig = true;

  enable =
    (config.hostOption.type == "minimal" || config.hostOption.type == "lite")
    && !config.targets.genericLinux.enable;
in {
  imports = [
    (import ./input.nix {inherit checkConfig;})
    ./keybind.nix
    ./window.nix

    ../notification/mako.nix
    ../runner/anyrun.nix
  ];

  config = lib.mkIf enable {
    wayland.windowManager.sway = {
      inherit enable;

      inherit checkConfig;

      config = {
        modifier = "Mod4";

        terminal = config.dp.term;
        menu = config.dp.dmenu;

        output = {
          "Virtual-1" = {
            mode = "1920x1080@60.000Hz";
          };
        };

        bars = [];
      };
    };

    programs = {
      swaylock.enable = enable;
    };

    services = {
      swayidle.enable = enable;
    };

    dp.colorpicker = "${pkgs.hyprpicker}/bin/hyprpicker -a";
  };
}
