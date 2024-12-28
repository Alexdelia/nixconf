{config, ...}: {
  imports = [
    ./keybind.nix
    ./window.nix
  ];

  wayland.windowManager.sway = {
    enable = config.hostOption.type == "minimal" || config.hostOption.type == "lite";

    config = {
      modifier = "Mod4";

      terminal = config.dp.term;

      output = {
        "Virtual-1" = {
          mode = "1920x1080@60.000Hz";
        };
      };
    };
  };
}
