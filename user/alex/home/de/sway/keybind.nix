{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.wayland.windowManager.sway.config) modifier;

  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";

  playerctl = "${pkgs.playerctl}/bin/playerctl";
  mpc = "${pkgs.mpc-cli}/bin/mpc";

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

    # sound
    "${modifier}+z" = "exec ${playerctl} play-pause";
    "${modifier}+x" = "exec ${playerctl} next";
    "${modifier}+Shift+z" = "exec ${mpc} toggle";
    "XF86AudioRaiseVolume" = "exec ${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+";
    "XF86AudioLowerVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 2%-";
    "XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";

    # brightness
    "XF86MonBrightnessDown" = "exec ${brightnessctl} set 2%-";
    "XF86MonBrightnessUp" = "exec ${brightnessctl} set 2%+";
  };
}
