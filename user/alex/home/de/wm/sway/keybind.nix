{
  config,
  lib,
  ...
}: let
  modifier = config.wayland.windowManager.sway.config.modifier;
in {
  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "${modifier}+Return" = "exec ${config.dp.term}";
    "${modifier}+Shift+q" = "kill";
  };
}
