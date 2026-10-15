{
  config,
  lib,
  ...
}:
let
  role = import ./role.nix;

  inherit (config.hostOption.spec) monitor;

  mkMode =
    m:
    "${toString m.width}x${toString m.height}"
    + lib.optionalString (m.refresh != null) "@${m.refresh}Hz";

  output =
    monitor
    |> lib.mapAttrs (
      _: m:
      {
        mode = mkMode m;
        position = "${toString m.x} ${toString m.y}";
      }
      // lib.optionalAttrs (m.scale != 1.0) { scale = toString m.scale; }
      // lib.optionalAttrs m.adaptiveSync { adaptive_sync = "on"; }
    );

  primary =
    let
      found = monitor |> lib.filterAttrs (_: m: m.primary) |> lib.attrNames;
    in
    if found == [ ] then null else lib.head found;

  media = monitor |> lib.filterAttrs (_: m: m.media) |> lib.attrNames;

  appWorkspace = lib.drop (role.globalFrom - 1) role.list;
  activityRole = lib.take (role.globalFrom - 1) role.list;
  appAssign =
    appWorkspace
    |> map (ws: {
      workspace = ws;
      output = primary;
    })
    |> lib.optionals (primary != null);
  defaultAssign =
    activityRole
    |> map (r: {
      workspace = "default:${r}";
      output = primary;
    })
    |> lib.optionals (primary != null);
  mediaAssign =
    media
    |> map (name: {
      workspace = "media";
      output = name;
    });
in
{
  config = lib.mkIf (monitor != { }) {
    wayland.windowManager.sway.config = {
      inherit output;
      workspaceOutputAssign = appAssign ++ defaultAssign ++ mediaAssign;
      startup = lib.optionals (primary != null && media != [ ]) [
        { command = "swaymsg 'workspace media; focus output ${primary}'"; }
      ];
    };
  };
}
