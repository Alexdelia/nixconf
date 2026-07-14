{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.wayland.windowManager.sway.config) modifier;

  notify = "${pkgs.libnotify}/bin/notify-send";
in {
  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    # apps
    "${modifier}+c" = "exec ${config.dp.term}";
    "${modifier}+b" = "exec ${config.dp.browser}";
    "${modifier}+k" = "exec ${config.dp.calculator}";

    # widgets
    "${modifier}+d" = "exec ${config.dp.dmenu}";
    "${modifier}+a" = "exec ${config.dp.infoHub or notify + " 'no infoHub'"}";
    "${modifier}+w" = "exec ${config.dp.powermenu or notify + " 'no powermenu'"}";

    # screen read
    "${modifier}+s" = "exec ${config.customScript.screenshot}";
    "${modifier}+i" = "exec ${config.customScript.imageEdit}";
    "${modifier}+q" = "exec ${config.dp.colorpicker}";

    # script
    "${modifier}+p" = "exec ${config.customScript.passwordGen} | ${config.dp.clipboard-copy}";

    # window manager
    "${modifier}+Shift+q" = "kill";
  };
}
