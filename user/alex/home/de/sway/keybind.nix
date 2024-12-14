{
  config,
  lib,
  ...
}: let
  inherit (config.wayland.windowManager.sway.config) modifier;
in {
  config = lib.mkIf (config.hostOption.type == "minimal") {
    wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
      "${modifier}+c" = "exec ${config.dp.term}";
      "${modifier}+b" = "exec ${config.dp.browser}";

      "${modifier}+Shift+q" = "kill";
    };
  };
}
