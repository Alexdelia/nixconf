{config, ...}:
#let
#bind = (mod, key, dispatcher, {
{
  wayland.windowManager.hyprland.settings.bind = [
    "$mod, C, exec, ${config.dp.term}"
    "$mod, B, exec, ${config.dp.browser}"
    # "$mod, C, exec, alacritty"
    # "$mod, B, exec, brave"

    "$mod SHIFT, Q, killactive,"
    "$mod SHIFT, M, exit,"
  ];
}
