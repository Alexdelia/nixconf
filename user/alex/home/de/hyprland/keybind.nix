{config, ...}: {
  wayland.windowManager.hyprland.settings.bind = [
    "$mod, C, exec, ${config.dp.term}"
    "$mod, B, exec, ${config.dp.browser}"

    "$mod SHIFT, Q, killactive,"
    "$mod SHIFT, M, exit,"
  ];
}
