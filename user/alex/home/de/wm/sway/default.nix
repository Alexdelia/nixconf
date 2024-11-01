{config, ...}: {
  imports = [
    # ./keybind.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";

      # terminal = config.dp.term;
      output = {
        "Virtual-1" = {
          mode = "1920x1080@60.000Hz";
        };
      };
    };
  };
}
