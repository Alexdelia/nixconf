{config, ...}: {
  imports = [
    ./keybind.nix
    ./window.nix

    ../notification/mako.nix
    ../runner/anyrun.nix
  ];

  wayland.windowManager.sway = {
    enable = config.hostOption.type == "minimal" || config.hostOption.type == "lite";

    config = {
      modifier = "Mod4";

      terminal = config.dp.term;
      menu = config.dp.dmenu;

      output = {
        "Virtual-1" = {
          mode = "1920x1080@60.000Hz";
        };
      };

      input = {
        "1267:12608:ELAN0001:00_04F3:3140_Touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
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
}
