{
  config,
  pkgs,
  lib,
  ...
}:
let
  singleton = {
    slack = {
      class = "Slack";
      desktop = 9;
      exec = "/usr/bin/slack"; # manual install, slack is not packaged for this host
    };
    brave = {
      class = "brave-browser";
      desktop = 10;
      exec = config.dp.browser;
    };
  };

  autostartEntry =
    name: app:
    pkgs.makeDesktopItem {
      inherit name;
      desktopName = name;
      inherit (app) exec;
      type = "Application";
      startupNotify = false;
    };
in
{
  programs.plasma.window-rules = lib.mapAttrsToList (name: app: {
    description = "singleton: ${name}";
    match.window-class = {
      value = app.class;
      type = "exact";
    };
    apply.desktops = {
      value = "Desktop_${toString app.desktop}";
      apply = "force";
    };
  }) singleton;

  xdg.configFile = lib.mapAttrs' (
    name: app:
    lib.nameValuePair "autostart/${name}.desktop" {
      source = "${autostartEntry name app}/share/applications/${name}.desktop";
    }
  ) singleton;
}
