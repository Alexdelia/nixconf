{
  config,
  lib,
  ...
}: {
  systemd.user.sessionVariables = lib.mapAttrs (_: lib.mkDefault) config.home.sessionVariables;
}
