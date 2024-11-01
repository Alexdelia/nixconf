{
  imports = [
    # ./keybind.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";

      #      terminal = "alacritty";
      output = {
        "Output Virtual-1" = {
          mode = "1920x1080@60.000Hz";
        };
      };
    };
  };
}
