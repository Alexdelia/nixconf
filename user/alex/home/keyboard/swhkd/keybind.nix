{
  config,
  pkgs,
  lib,
  ...
}: let
  keybind = let
    playerctl = "${pkgs.playerctl}/bin/playerctl";
    mpc = "${pkgs.mpc}/bin/mpc";

    wpctl = "${pkgs.wireplumber}/bin/wpctl";
    baseVolumeChange = 2;
    highVolumeChange = baseVolumeChange * 4;

    brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
    baseBrightnessChange = 2;
    highBrightnessChange = baseBrightnessChange * 4;
  in {
    # apps
    # "super + c" = config.dp.term;
    # "super + b" = config.dp.browser;
    # "super + m" = config.dp.music;
    # "super + k" = config.dp.calculator;
    # "super + f" = config.dp.fileManager;

    # widgets
    # "super + d" = config.dp.dmenu;
    # "super + a" = config.dp.infoHub;
    # "super + w" = config.dp.powermenu;

    # screen read
    # "super + s" = "screenshot";
    # "super + q" = "colorpicker";

    # media audio
    "super + z" = "${playerctl} play-pause";
    "xf86audioplay" = "${playerctl} play-pause";
    "super + shift + z" = "${mpc} toggle";
    "super + x" = "${playerctl} next";
    "xf86audionext" = "${playerctl} next";
    "super + shift + x" = "${mpc} next";
    "xf86audioprev" = "${playerctl} previous";
    "xf86audiostop" = "${playerctl} stop";

    # volume
    "volumeup" = "${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ ${toString baseVolumeChange}%+";
    "volumedown" = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ ${toString baseVolumeChange}%-";
    "shift + volumeup" = "${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ ${toString highVolumeChange}%+";
    "shift + volumedown" = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ ${toString highVolumeChange}%-";
    "mute" = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";

    # brightness
    "brightnessup" = "${brightnessctl} set ${toString baseBrightnessChange}%+";
    "brightnessdown" = "${brightnessctl} set ${toString baseBrightnessChange}%-";
    "shift + brightnessup" = "${brightnessctl} set ${toString highBrightnessChange}%+";
    "shift + brightnessdown" = "${brightnessctl} set ${toString highBrightnessChange}%-";
  };

  isNonNixos = config.targets.genericLinux.enable;
  localConfig = "${config.xdg.configHome}/swhkd/local.swhkdrc";
  localInclude = lib.optionalString isNonNixos "include ${localConfig}\n";
in {
  xdg.configFile."swhkd/swhkdrc".text =
    localInclude
    + lib.concatStringsSep "\n"
    (lib.mapAttrsToList (hotkey: command: "${hotkey}\n\t${command}\n") keybind);

  home.activation = lib.mkIf isNonNixos {
    swhkdLocalConfig =
      lib.hm.dag.entryAfter ["writeBoundary"]
      /*
      bash
      */
      ''
        if [[ ! -e ${lib.escapeShellArg localConfig} ]]; then
        	run mkdir -p ${lib.escapeShellArg (dirOf localConfig)}
        	run touch ${lib.escapeShellArg localConfig}
        fi
      '';
  };
}
