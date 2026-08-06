{
  config,
  pkgs,
  lib,
  ...
}:
let
  qdbus = "${pkgs.kdePackages.qttools}/bin/qdbus";

  singleton = {
    slack = {
      class = "slack";
      desktop = 9;
      exec = "/usr/bin/slack"; # manual install, slack is not packaged for this host
    };
    brave = {
      class = "brave-browser";
      desktop = 10;
      exec = config.dp.browser;
    };
  };

  classes = lib.mapAttrsToList (_: app: app.class) singleton;

  autostartEntry =
    name: app:
    pkgs.makeDesktopItem {
      inherit name;
      desktopName = name;
      inherit (app) exec;
      type = "Application";
      startupNotify = false;
    };

  stayScript = pkgs.writeText "plasma-singleton-stay.js" ''
    const home = workspace.currentDesktop;
    const pending = new Set(${builtins.toJSON classes});
    const deadline = Date.now() + 120000;

    // kwin switches desktop before the window is knowable:
    // on `currentDesktopChanged` the active window is still `null`
    workspace.windowActivated.connect(w => {
      if (!w || pending.size === 0 || Date.now() > deadline) {
        return;
      }

      if (!pending.has(w.resourceClass)) {
        return;
      }

      pending.delete(w.resourceClass);
      workspace.currentDesktop = home;
    });
  '';

  stayLoad = pkgs.writeShellApplication {
    name = "plasma-singleton-stay-load";
    text = ''
      ${qdbus} org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript singleton-stay >/dev/null 2>&1 || true
      ${qdbus} org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript ${stayScript} singleton-stay >/dev/null
      ${qdbus} org.kde.KWin /Scripting org.kde.kwin.Scripting.start >/dev/null
    '';
  };
in
{
  programs.plasma.window-rules = lib.mapAttrsToList (name: app: {
    description = "singleton: ${name}";
    match.window-class = {
      value = app.class;
      type = "exact";
      match-whole = false;
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

  systemd.user.services.plasma-singleton-stay = {
    Unit = {
      Description = "keep the login desktop when singleton apps autostart";
      PartOf = [ "graphical-session.target" ];
      After = [
        "graphical-session.target"
        "plasma-kwin_wayland.service"
      ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe stayLoad;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
