{
  config,
  lib,
  ...
}: let
  checkConfig = true;
in {
  imports = [
    ./input.nix
    (import ./keybind.nix {inherit checkConfig;})
    ./window.nix

    ../notification/mako.nix
    ../runner/anyrun.nix
  ];

  config = lib.mkIf (config.hostOption.type == "minimal" || config.hostOption.type == "lite") {
    wayland.windowManager.sway = {
      enable = config.hostOption.type == "minimal" || config.hostOption.type == "lite";

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
      swaylock.enable = false;
    };

    services = {
      swayidle = {
        enable = true;
      };
    };
  };
}
