{config, ...}: {
  imports = [
    ./keybind.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    xwayland.enable = true;

    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = config.dp.term;
    };
  };
}
