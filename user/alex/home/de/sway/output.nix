{
  config,
  lib,
  ...
}: let
  role = import ./role.nix;

  inherit (config.hostOption.spec) monitor;

  mkMode = m: "${toString m.width}x${toString m.height}" + lib.optionalString (m.refresh != null) "@${m.refresh}Hz";

  output =
    lib.mapAttrs (
      _: m:
        {
          mode = mkMode m;
          position = "${toString m.x} ${toString m.y}";
        }
        // lib.optionalAttrs (m.scale != 1.0) {scale = toString m.scale;}
        // lib.optionalAttrs m.adaptiveSync {adaptive_sync = "on";}
    )
    monitor;

  primary = let
    found = lib.attrNames (lib.filterAttrs (_: m: m.primary) monitor);
  in
    if found == []
    then null
    else lib.head found;

  media = lib.attrNames (lib.filterAttrs (_: m: m.media) monitor);

  appWorkspace = lib.drop (role.globalFrom - 1) role.list;
  activityRole = lib.take (role.globalFrom - 1) role.list;
  appAssign = lib.optionals (primary != null) (map (ws: {
      workspace = ws;
      output = primary;
    })
    appWorkspace);
  defaultAssign = lib.optionals (primary != null) (map (r: {
      workspace = "default:${r}";
      output = primary;
    })
    activityRole);
  mediaAssign =
    map (name: {
      workspace = "media";
      output = name;
    })
    media;
in {
  config = lib.mkIf (monitor != {}) {
    wayland.windowManager.sway.config = {
      inherit output;
      workspaceOutputAssign = appAssign ++ defaultAssign ++ mediaAssign;
      startup = lib.optionals (primary != null && media != []) [
        {command = "swaymsg 'workspace media; focus output ${primary}'";}
      ];
    };
  };
}
