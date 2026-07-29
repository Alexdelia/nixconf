{
  config,
  pkgs,
  lib,
  ...
}: let
  keybind = let
    notifyError = "${pkgs.libnotify}/bin/notify-send -u critical";
    withNotifyMissing = name:
      lib.attrByPath (lib.splitString "." name) "${notifyError} 'no ${name}'" config;

    playerctl = "${pkgs.playerctl}/bin/playerctl";
    mpc = "${pkgs.mpc}/bin/mpc";
  in {
    # app
    "super + c" = config.dp.term;
    "super + b" = config.dp.browser;
    "super + m" = withNotifyMissing "dp.music";
    "super + k" = config.dp.calculator;
    "super + f" = withNotifyMissing "dp.fileManager";

    # widget
    "super + d" = config.dp.dmenu;
    "super + a" = withNotifyMissing "dp.infoHub";
    "super + w" = withNotifyMissing "dp.powerMenu";

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
