{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.wayland.windowManager.sway.config) modifier;

  playerctl = "${pkgs.playerctl}/bin/playerctl";

  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  baseVolumeChange = 2;
  highVolumeChange = baseVolumeChange * 4;

  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  baseBrightnessChange = 2;
  highBrightnessChange = baseBrightnessChange * 4;
in
{
  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    # screen read
    "${modifier}+s" = "exec ${config.customScript.screenshot}";
    "${modifier}+i" = "exec ${config.customScript.imageEdit}";
    "${modifier}+q" = "exec ${config.dp.colorpicker}";

    # script
    "${modifier}+p" = "exec ${config.customScript.passwordGen} | ${config.dp.clipboard-copy}";

    # window manager
    "${modifier}+Shift+q" = "kill";

    # media audio
    "XF86AudioPlay" = "exec ${playerctl} play-pause";
    "XF86AudioNext" = "exec ${playerctl} next";
    "XF86AudioPrev" = "exec ${playerctl} previous";
    "XF86AudioStop" = "exec ${playerctl} stop";

    # volume
    "XF86AudioRaiseVolume" =
      "exec ${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ ${toString baseVolumeChange}%+";
    "XF86AudioLowerVolume" =
      "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ ${toString baseVolumeChange}%-";
    "Shift+XF86AudioRaiseVolume" =
      "exec ${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ ${toString highVolumeChange}%+";
    "Shift+XF86AudioLowerVolume" =
      "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ ${toString highVolumeChange}%-";
    "XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";

    # brightness
    "XF86MonBrightnessUp" = "exec ${brightnessctl} set ${toString baseBrightnessChange}%+";
    "XF86MonBrightnessDown" = "exec ${brightnessctl} set ${toString baseBrightnessChange}%-";
    "Shift+XF86MonBrightnessUp" = "exec ${brightnessctl} set ${toString highBrightnessChange}%+";
    "Shift+XF86MonBrightnessDown" = "exec ${brightnessctl} set ${toString highBrightnessChange}%-";
  };
}
