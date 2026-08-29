{
  config,
  pkgs,
  lib,
  ...
}:
let
  role = import ./role.nix;

  inherit (config.wayland.windowManager.sway.config) modifier;

  mediaEnabled = lib.filterAttrs (_: m: m.media) config.hostOption.spec.monitor != { };

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

    cur_role() {
    	local suffix ri k r
    	suffix="$(swaymsg -t get_workspaces | jaq -r '.[] | select(.focused).name')"
    	suffix="''${suffix##*:}"
    	ri=1
    	k=0
    	for r in "''${role[@]}"; do
    		k=$((k + 1))
    		if [ "$r" = "$suffix" ]; then ri="$k"; break; fi
    	done
    	if [ "$ri" -ge "$global_from" ]; then ri=1; fi
    	printf '%s' "$ri"
    }

    activity_create() {
    	local id ri
    	id="branch-$(date +%H%M%S)"
    	rg -qFx "$id" "$state/list" || printf '%s\n' "$id" >>"$state/list"
    	ri="$(cur_role)"
    	printf '%s\n' "$id" >"$state/current"
    	swaymsg workspace "$(ws_name "$ri" "$id")" >/dev/null
    }

    # empty = no window in the activity's per-activity workspaces (globals don't count)
    activity_empty() {
    	local act="$1" cnt
    	cnt="$(swaymsg -t get_tree | jaq --arg p "$act:" '
    		[ recurse(.nodes[]?, .floating_nodes[]?)
    			| select(.type == "workspace" and (.name | startswith($p)))
    			| recurse(.nodes[]?, .floating_nodes[]?)
    			| select((.type == "con" or .type == "floating_con") and (.nodes | length) == 0)
    		] | length')"
    	[ "$cnt" -eq 0 ]
    }
  '';

  mkScript =
    name: body:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = with pkgs; [
        sway
        jaq
        uutils-coreutils-noprefix
        ripgrep
      ];
      inheritPath = false;
      excludeShellChecks = [ "SC2016" ];
      text = prelude + body;
    };

  wsSwitch = mkScript "sway-ws-switch" /* bash */ ''
    swaymsg workspace "$(ws_name "$1" "$(cur)")" >/dev/null
  '';

  wsMove = mkScript "sway-ws-move" /* bash */ ''
    name="$(ws_name "$1" "$(cur)")"
    swaymsg "move container to workspace \"$name\"" >/dev/null
    swaymsg workspace "$name" >/dev/null
  '';

  # super+shift+0 toggles the focused window between browser (role 10) and media
  wsMoveMedia = mkScript "sway-ws-move-media" /* bash */ ''
    media_enabled=${if mediaEnabled then "1" else "0"}
    browser="$(ws_name 10 "$(cur)")"
    focused="$(swaymsg -t get_workspaces | jaq -r '.[] | select(.focused).name')"

    if [ "$focused" = media ]; then
    	target="$browser"
    elif [ "$focused" = "$browser" ] && [ "$media_enabled" = 1 ]; then
    	target=media
    else
    	target="$browser"
    fi

    swaymsg "move container to workspace \"$target\"" >/dev/null
    swaymsg workspace "$target" >/dev/null
  '';

  activityCreate = mkScript "sway-activity-create" /* bash */ ''
    activity_create
  '';

  activityMove = mkScript "sway-activity-move" /* bash */ ''
    ri="$(cur_role)"
    id="branch-$(date +%H%M%S)"
    rg -qFx "$id" "$state/list" || printf '%s\n' "$id" >>"$state/list"
    target="$(ws_name "$ri" "$id")"
    swaymsg "move container to workspace \"$target\"" >/dev/null
    printf '%s\n' "$id" >"$state/current"
    swaymsg workspace "$target" >/dev/null
  '';

  activityCycle = mkScript "sway-activity-cycle" /* bash */ ''
    mapfile -t acts <"$state/list"
    n="''${#acts[@]}"
    if [ "$n" -lt 2 ]; then activity_create; exit 0; fi

    c="$(cur)"
    i=0
    for a in "''${acts[@]}"; do
    	if [ "$a" = "$c" ]; then break; fi
    	i=$((i + 1))
    done
    j=$(((i + 1) % n))
    next="''${acts[$j]}"

    ri="$(cur_role)"
    printf '%s\n' "$next" >"$state/current"
    swaymsg workspace "$(ws_name "$ri" "$next")" >/dev/null
  '';

  activityClose = mkScript "sway-activity-close" /* bash */ ''
    c="$(cur)"
    if [ "$c" = default ]; then exit 0; fi

    last=$((global_from - 1))
    for i in $(seq 1 "$last"); do
    	from="$(ws_name "$i" "$c")"
    	to="$(ws_name "$i" default)"
    	mapfile -t ids < <(swaymsg -t get_tree | jaq -r --arg ws "$from" '
    		recurse(.nodes[]?, .floating_nodes[]?)
    		| select(.type == "workspace" and .name == $ws)
    		| recurse(.nodes[]?, .floating_nodes[]?)
    		| select((.type == "con" or .type == "floating_con") and (.nodes | length) == 0)
    		| .id')
    	for id in "''${ids[@]}"; do
    		swaymsg "[con_id=$id] move container to workspace \"$to\"" >/dev/null
    	done
    done

    rg -vFx "$c" "$state/list" >"$state/list.tmp"
    mv "$state/list.tmp" "$state/list"
    printf 'default\n' >"$state/current"
    swaymsg workspace "$(ws_name 1 default)" >/dev/null
  '';

  activityReap = mkScript "sway-activity-reap" /* bash */ ''
    reap() {
    	local c ri m idx off cand target
    	c="$(cur)"
    	[ "$c" = default ] && return 0
    	activity_empty "$c" || return 0

    	mapfile -t acts <"$state/list"
    	m="''${#acts[@]}"
    	idx=0
    	for ((k = 0; k < m; k++)); do
    		if [ "''${acts[$k]}" = "$c" ]; then idx="$k"; break; fi
    	done

    	ri="$(cur_role)"
    	rg -vFx "$c" "$state/list" >"$state/list.tmp"
    	mv "$state/list.tmp" "$state/list"

    	target=default
    	for ((off = 1; off < m; off++)); do
    		cand="''${acts[$(((idx + off) % m))]}"
    		if [ "$cand" != "$c" ]; then target="$cand"; break; fi
    	done

    	printf '%s\n' "$target" >"$state/current"
    	swaymsg workspace "$(ws_name "$ri" "$target")" >/dev/null
    }

    swaymsg -t subscribe -m '["window"]' | while read -r ev; do
    	[ "$(jaq -r '.change' <<<"$ev")" = close ] || continue
    	reap
    done
  '';

  gridBind = lib.listToAttrs (
    lib.concatMap (
      i:
      let
        key = if i == 10 then "0" else toString i;
      in
      [
        {
          name = "${modifier}+${key}";
          value = "exec ${wsSwitch}/bin/sway-ws-switch ${toString i}";
        }
        {
          name = "${modifier}+Shift+${key}";
          value = "exec ${wsMove}/bin/sway-ws-move ${toString i}";
        }
      ]
    ) (lib.range 1 10)
  );

  activityBind = {
    "${modifier}+grave" = "exec ${activityCreate}/bin/sway-activity-create";
    "${modifier}+Shift+grave" = "exec ${activityMove}/bin/sway-activity-move";
    "${modifier}+Tab" = "exec ${activityCycle}/bin/sway-activity-cycle";
    "${modifier}+Control+w" = "exec ${activityClose}/bin/sway-activity-close";
  };

  mediaToggleBind."${modifier}+Shift+0" = "exec ${wsMoveMedia}/bin/sway-ws-move-media";
in
{
  config = lib.mkIf config.wayland.windowManager.sway.enable {
    home.packages = [
      wsSwitch
      wsMove
      wsMoveMedia
      activityCreate
      activityMove
      activityCycle
      activityClose
    ];

    wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault (
      gridBind // activityBind // mediaToggleBind
    );

    systemd.user.services.sway-activity-reap = {
      Unit = {
        Description = "auto-delete empty sway activity";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${activityReap}/bin/sway-activity-reap";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
