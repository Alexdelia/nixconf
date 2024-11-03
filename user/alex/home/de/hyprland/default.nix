{config, ...}: {
  imports = [
    ./input.nix
    ./keybind.nix
    ./monitor.nix
    ./appearance.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    xwayland.enable = true;

    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = config.dp.term;
      misc.font_family = "monospace";
    };
  };

  stylix.targets.hyprland.enable = false;
}
