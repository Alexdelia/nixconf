{
  config,
  pkgs,
  lib,
  ...
}: let
  keybind = let
    notify = "${pkgs.libnotify}/bin/notify-send";

    playerctl = "${pkgs.playerctl}/bin/playerctl";
    mpc = "${pkgs.mpc}/bin/mpc";
  in {
    # app
    "super + c" = config.dp.term;
    "super + b" = config.dp.browser;
    "super + m" = config.dp.music;
    "super + k" = config.dp.calculator;
    "super + f" = "${config.dp.fileManager or notify + " 'no fileManager'"}";

    # widget
    # "super + d" = config.dp.dmenu;
    # "super + a" = config.dp.infoHub;
    # "super + w" = config.dp.powermenu;

    # screen read
    # "super + s" = "screenshot";
    # "super + q" = "colorpicker";

    # media audio
    "super + z" = "${playerctl} play-pause";
    "super + shift + z" = "${mpc} toggle";
    "super + x" = "${playerctl} next";
    "super + shift + x" = "${mpc} next";
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
