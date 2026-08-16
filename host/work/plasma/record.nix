{
  pkgs,
  lib,
  ...
}:
let
  spectacle = "/usr/bin/spectacle";

  mode = import ../../../user/alex/home/de/notification/mode.nix;

  maxRecordSec = 4 * 60 * 60;

  desktopId = "net.local.record-region";

  recordRegion = pkgs.writeShellApplication {
    name = "record-region";

    runtimeInputs = with pkgs; [
      mako
      jq
      procps
      uutils-coreutils-noprefix
    ];

    text = ''
      lastNotificationId() {
        { makoctl list -j; makoctl history -j; } | jq -s '[.[][].id] | max // 0'
      }

      unhide() {
        makoctl mode -r ${mode.dnd} >/dev/null
      }

      before="$(lastNotificationId)"

      makoctl mode -a ${mode.dnd} >/dev/null
      trap unhide EXIT

      ${spectacle} -R region

      appeared=$((SECONDS + 3))
      while [ "$SECONDS" -lt "$appeared" ]; do
        if pgrep -x spectacle >/dev/null; then break; fi
        sleep 0.1
      done

      deadline=$((SECONDS + ${toString maxRecordSec}))
      while [ "$SECONDS" -lt "$deadline" ]; do
        if ! pgrep -x spectacle >/dev/null; then break; fi
        sleep 1
      done

      unhide
      trap - EXIT

      held="$(makoctl history -j | jq --argjson before "$before" '[.[] | select(.id > $before)] | length')"
      for _ in $(seq 1 "$held"); do
        makoctl restore
      done
    '';
  };
in
{
  xdg.desktopEntries.${desktopId} = {
    name = "record-region";
    exec = lib.getExe recordRegion;
    type = "Application";
    noDisplay = true;
    startupNotify = false;
    settings."X-KDE-GlobalAccel-CommandShortcut" = "true";
  };

  programs.plasma.shortcuts."services/${desktopId}.desktop"._launch = "Meta+Shift+S";
}
