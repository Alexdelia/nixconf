{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.hostOption.spec) monitor;

  mediaEnabled = monitor |> lib.attrValues |> lib.any (m: m.media);

  screen =
    monitor |> lib.mapAttrsToList (name: m: "${name}:${toString m.height}") |> lib.concatStringsSep ";";

  start = pkgs.writeShellApplication {
    name = "power-tray-start";
    text = ''
      ${config.customScript.isMediaDefaultTime} || exit 0
      exec ${config.dp.powerTray}
    '';
  };
in
{
  config = lib.mkIf (config.wayland.windowManager.sway.enable && mediaEnabled) {
    systemd.user.services.power-tray = {
      Unit = {
        Description = "power icon for media session, on every screen";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${start}/bin/power-tray-start";
        Environment = [
          "WIDGET_TRAY_SCREEN=${screen}"
          "WIDGET_POWER_MENU=${config.dp.powerMenu}"
        ];
        Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
