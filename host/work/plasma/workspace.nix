{
  config,
  pkgs,
  lib,
  ...
}: let
  role = import ../../../user/alex/home/de/sway/role.nix;

  qdbus = "${pkgs.kdePackages.qttools}/bin/qdbus";

  wallpaper = toString config.programs.plasma.workspace.wallpaper;

  prelude = ''
    global_from=${toString role.globalFrom}

    am() {
      local method="$1"
      shift
      ${qdbus} org.kde.ActivityManager /ActivityManager/Activities "org.kde.ActivityManager.Activities.$method" "$@"
    }

    kwin_js() {
      local name="$1" js="$2" file
      file="$(mktemp --suffix=.js)"
      printf '%s\n' "$js" >"$file"
      ${qdbus} org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$name" >/dev/null 2>&1 || true
      ${qdbus} org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$file" "$name" >/dev/null
      ${qdbus} org.kde.KWin /Scripting org.kde.kwin.Scripting.start >/dev/null
      ${qdbus} org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$name" >/dev/null 2>&1 || true
      rm -f "$file"
    }

    globalize() {
      kwin_js activity-globalize "
        for (const w of workspace.windowList()) {
          if (w.desktops.some(d => d.x11DesktopNumber >= $global_from)) {
            w.activities = [];
          }
        }
      "
    }

    keep_wallpaper() {
      ${qdbus} org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        const group = ['Wallpaper', 'org.kde.image', 'General'];

        const image = desktops().reduce((found, d) => {
          d.currentConfigGroup = group;
          return found || d.readConfig('Image');
        }, null) || '${wallpaper}';

        desktops().forEach(d => {
          d.currentConfigGroup = group;
          if (!d.readConfig('Image')) {
            d.wallpaperPlugin = 'org.kde.image';
            d.writeConfig('Image', image);
          }
        });
      " >/dev/null
    }

    new_activity() {
      am AddActivity "branch-$(date +%H%M%S)"
    }

    base_activity() {
      local id
      while read -r id; do
        case "$(am ActivityName "$id")" in
          branch-*) ;;
          *)
            printf '%s' "$id"
            return 0
            ;;
        esac
      done < <(am ListActivities)
      am CurrentActivity
    }
  '';

  mkScript = name: body:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [pkgs.uutils-coreutils-noprefix];
      text = prelude + body;
    };

  activityCreate =
    mkScript "plasma-activity-create"
    /*
    bash
    */
    ''
      am SetCurrentActivity "$(new_activity)" >/dev/null
      globalize
      keep_wallpaper
    '';

  activityMove =
    mkScript "plasma-activity-move"
    /*
    bash
    */
    ''
      id="$(new_activity)"
      kwin_js activity-move "
        const w = workspace.activeWindow;
        if (w) {
          w.activities = [\"$id\"];
        }
      "
      am SetCurrentActivity "$id" >/dev/null
      globalize
      keep_wallpaper
    '';

  activityClose =
    mkScript "plasma-activity-close"
    /*
    bash
    */
    ''
      cur="$(am CurrentActivity)"
      base="$(base_activity)"
      if [ "$cur" = "$base" ]; then exit 0; fi

      kwin_js activity-close "
        for (const w of workspace.windowList()) {
          if (w.activities.length === 1 && w.activities[0] === \"$cur\") {
            w.activities = [\"$base\"];
          }
        }
      "

      am SetCurrentActivity "$base" >/dev/null
      am RemoveActivity "$cur"
    '';

  wsMove =
    mkScript "plasma-ws-move"
    /*
    bash
    */
    ''
      kwin_js ws-move "
        const d = workspace.desktops[$1 - 1];
        const w = workspace.activeWindow;
        if (d) {
          if (w) {
            w.desktops = [d];
          }
          workspace.currentDesktop = d;
        }
      "
    '';

  shifted = ["!" "@" "#" "$" "%" "^" "&" "*" "(" ")"];

  desktops = lib.range 1 (builtins.length role.list);

  launcher = script: {
    inherit (script) name;
    exec = lib.getExe script;
    noDisplay = true;
    startupNotify = false;
    type = "Application";
  };
in {
  home.packages = [activityCreate activityMove activityClose wsMove];

  xdg.desktopEntries = {
    "net.local.activity-create" = launcher activityCreate;
    "net.local.activity-move" = launcher activityMove;
    "net.local.activity-close" = launcher activityClose;

    "net.local.ws-move" =
      (launcher wsMove)
      // {
        actions = lib.listToAttrs (map (i: {
            name = toString i;
            value = {
              name = "move window to ${builtins.elemAt role.list (i - 1)}";
              exec = "${lib.getExe wsMove} ${toString i}";
            };
          })
          desktops);
      };
  };

  programs.plasma.shortcuts = {
    "services/net.local.activity-create.desktop"._launch = "Meta+`";
    "services/net.local.activity-move.desktop"._launch = "Meta+~";
    "services/net.local.activity-close.desktop"._launch = "Meta+Ctrl+W";

    "services/net.local.ws-move.desktop" = lib.listToAttrs (map (i: {
        name = toString i;
        value = "Meta+${builtins.elemAt shifted (i - 1)}";
      })
      desktops);

    plasmashell."switch to next activity" = "Meta+Tab";

    kwin = {
      "Walk Through Windows" = "Alt+Tab";
      "Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
      "Walk Through Windows of Current Application" = "Alt+`";
      "Walk Through Windows of Current Application (Reverse)" = "Alt+~";
    };
  };
}
