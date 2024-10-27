{
  imports = [
    # ./hyprland
    # ./gnome
    # (import ./sway { inherit users; })
  ];

  stylix.targets.chromium.enable = false;
}
