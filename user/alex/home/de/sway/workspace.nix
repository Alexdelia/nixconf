{
  config,
  pkgs,
  lib,
  ...
}: let
  role = import ./role.nix;

  inherit (config.wayland.windowManager.sway.config) modifier;

  prelude = ''
    state="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/sway-activity"
    mkdir -p "$state"
    [ -f "$state/list" ] || printf 'default\n' >"$state/list"
    [ -f "$state/current" ] || printf 'default\n' >"$state/current"

    role=(${lib.concatStringsSep " " role.list})
    global_from=${toString role.globalFrom}

    ws_name() {
      local i="$1"
      local act="$2"
      local name="''${role[$((i - 1))]}"
      if [ "$i" -ge "$global_from" ]; then
        printf '%s' "$name"
      else
        printf '%s:%s' "$act" "$name"
      fi
    }

    cur() { printf '%s' "$(<"$state/current")"; }
  '';

  mkScript = name: body:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [pkgs.sway pkgs.jq pkgs.coreutils pkgs.gnugrep];
      text = prelude + body;
    };

  wsSwitch =
    mkScript "sway-ws-switch"
    /*
    bash
    */
    ''
      swaymsg workspace "$(ws_name "$1" "$(cur)")" >/dev/null
    '';

  wsMove =
    mkScript "sway-ws-move"
    /*
    bash
    */
    ''
      name="$(ws_name "$1" "$(cur)")"
      swaymsg "move container to workspace \"$name\"" >/dev/null
      swaymsg workspace "$name" >/dev/null
    '';

  activityCreate =
    mkScript "sway-activity-create"
    /*
    bash
    */
    ''
      id="branch-$(date +%H%M%S)"
      grep -qxF "$id" "$state/list" || printf '%s\n' "$id" >>"$state/list"
      printf '%s\n' "$id" >"$state/current"
      swaymsg workspace "$(ws_name 1 "$id")" >/dev/null
    '';

  activityCycle =
    mkScript "sway-activity-cycle"
    /*
    bash
    */
    ''
      dir="''${1:-next}"
      mapfile -t acts <"$state/list"
      n="''${#acts[@]}"
      if [ "$n" -lt 2 ]; then exit 0; fi

      c="$(cur)"
      i=0
      for a in "''${acts[@]}"; do
        if [ "$a" = "$c" ]; then break; fi
        i=$((i + 1))
      done
      if [ "$dir" = prev ]; then j=$(((i - 1 + n) % n)); else j=$(((i + 1) % n)); fi
      next="''${acts[$j]}"
      printf '%s\n' "$next" >"$state/current"

      # land on the same role index as the focused workspace, else role 1
      suffix="$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused).name')"
      suffix="''${suffix##*:}"
      ri=1
      k=0
      for r in "''${role[@]}"; do
        k=$((k + 1))
        if [ "$r" = "$suffix" ]; then ri="$k"; break; fi
      done
      if [ "$ri" -ge "$global_from" ]; then ri=1; fi
      swaymsg workspace "$(ws_name "$ri" "$next")" >/dev/null
    '';

  activityClose =
    mkScript "sway-activity-close"
    /*
    bash
    */
    ''
      c="$(cur)"
      if [ "$c" = default ]; then exit 0; fi

      last=$((global_from - 1))
      for i in $(seq 1 "$last"); do
        from="$(ws_name "$i" "$c")"
        to="$(ws_name "$i" default)"
        mapfile -t ids < <(swaymsg -t get_tree | jq -r --arg ws "$from" '
          recurse(.nodes[]?, .floating_nodes[]?)
          | select(.type == "workspace" and .name == $ws)
          | recurse(.nodes[]?, .floating_nodes[]?)
          | select((.type == "con" or .type == "floating_con") and (.nodes | length) == 0)
          | .id')
        for id in "''${ids[@]}"; do
          swaymsg "[con_id=$id] move container to workspace \"$to\"" >/dev/null
        done
      done

      grep -vxF "$c" "$state/list" >"$state/list.tmp"
      mv "$state/list.tmp" "$state/list"
      printf 'default\n' >"$state/current"
      swaymsg workspace "$(ws_name 1 default)" >/dev/null
    '';

  gridBind = lib.listToAttrs (lib.concatMap (i: let
    key =
      if i == 10
      then "0"
      else toString i;
  in [
    {
      name = "${modifier}+${key}";
      value = "exec ${wsSwitch}/bin/sway-ws-switch ${toString i}";
    }
    {
      name = "${modifier}+Shift+${key}";
      value = "exec ${wsMove}/bin/sway-ws-move ${toString i}";
    }
  ]) (lib.range 1 10));

  activityBind = {
    "${modifier}+Control+n" = "exec ${activityCreate}/bin/sway-activity-create";
    "${modifier}+Control+Right" = "exec ${activityCycle}/bin/sway-activity-cycle next";
    "${modifier}+Control+Left" = "exec ${activityCycle}/bin/sway-activity-cycle prev";
    "${modifier}+Control+w" = "exec ${activityClose}/bin/sway-activity-close";
  };
in {
  config = lib.mkIf config.wayland.windowManager.sway.enable {
    home.packages = [wsSwitch wsMove activityCreate activityCycle activityClose];

    wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault (gridBind // activityBind);
  };
}
