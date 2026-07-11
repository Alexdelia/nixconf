{pkgs, ...}: let
  qdbus = ''$(command -v qdbus6 || command -v qdbus || echo ${pkgs.kdePackages.qttools}/bin/qdbus)'';
  am = "${qdbus} org.kde.ActivityManager /ActivityManager/Activities";

  create = pkgs.writeShellScript "activity-create" ''
    set -eu
    id=$(${am} org.kde.ActivityManager.Activities.AddActivity "branch-$(date +%H%M%S)")
    ${am} org.kde.ActivityManager.Activities.SetCurrentActivity "$id"
  '';

  cycle = pkgs.writeShellScript "activity-cycle" ''
    set -eu
    dir="''${1:-next}"
    cur=$(${am} org.kde.ActivityManager.Activities.CurrentActivity)
    mapfile -t acts < <(${am} org.kde.ActivityManager.Activities.ListActivities | tr ' ' '\n' | sed '/^$/d')
    n=''${#acts[@]}
    [ "$n" -lt 2 ] && exit 0
    i=0; for a in "''${acts[@]}"; do [ "$a" = "$cur" ] && break; i=$((i+1)); done
    if [ "$dir" = "prev" ]; then j=$(((i - 1 + n) % n)); else j=$(((i + 1) % n)); fi
    ${am} org.kde.ActivityManager.Activities.SetCurrentActivity "''${acts[$j]}"
  '';

  close = pkgs.writeShellScript "activity-close" ''
    set -eu
    cur=$(${am} org.kde.ActivityManager.Activities.CurrentActivity)
    ${cycle} prev
    ${am} org.kde.ActivityManager.Activities.RemoveActivity "$cur"
  '';
in {
  programs.plasma.hotkeys.commands = {
    activity-create = {
      comment = "create a new activity and switch to it";
      command = "${create}";
      key = "Meta+Ctrl+N";
    };
    activity-next = {
      comment = "cycle to the next activity";
      command = "${cycle} next";
      key = "Meta+Ctrl+Right";
    };
    activity-prev = {
      comment = "cycle to the previous activity";
      command = "${cycle} prev";
      key = "Meta+Ctrl+Left";
    };
    activity-close = {
      comment = "remove current activity";
      command = "${close}";
      key = "Meta+Ctrl+W";
    };
  };
}
