{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.wayland.windowManager.sway.config) modifier;

  playerctl = "${pkgs.playerctl}/bin/playerctl";
  mpc = "${pkgs.mpc-cli}/bin/mpc";
in {
  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    # apps
    "${modifier}+c" = "exec ${config.dp.term}";
    "${modifier}+b" = "exec ${config.dp.browser}";
    "${modifier}+k" = "exec ${config.dp.calculator}";

    # widgets
    "${modifier}+d" = "exec ${config.dp.dmenu}";
    # "${modifier}+a" = "exec ${config.dp.infoHub}";
    # "${modifier}+w" = "exec ${config.dp.powermenu}";

    # screen read
    "${modifier}+s" = "exec ${config.customScript.screenshot}";
    "${modifier}+i" = "exec ${config.customScript.imageEdit}";
    "${modifier}+q" = "exec ${config.dp.colorpicker}";

    # script
    "${modifier}+p" = "exec ${config.customScript.passwordGen} | ${config.dp.clipboard-copy}";

    # window manager
    "${modifier}+Shift+q" = "kill";

    # sound
    "${modifier}+z" = "${playerctl} play-pause";
    "${modifier}+x" = "${playerctl} next";
    "${modifier}+Shift+z" = "${mpc} toggle";
  };
}
