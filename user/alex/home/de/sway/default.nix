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
    ./output.nix
    ./workspace.nix
    ./singleton.nix

    ../notification/mako.nix
    ../runner/fuzzel.nix
  ];

  config = lib.mkIf enable {
    wayland.windowManager.sway = {
      inherit enable;

      inherit checkConfig;

      config = {
        modifier = "Mod4";

        terminal = config.dp.term;
        menu = config.dp.dmenu;

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
