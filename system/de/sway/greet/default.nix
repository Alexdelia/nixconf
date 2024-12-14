{
  users,
  lib,
  config,
  ...
}: {
  # imports = [
  #   ./regreet
  # ];

  config = lib.mkIf (config.hostOption.type == "minimal") {
    services.getty.autologinUser = builtins.elemAt users 0;
  };
}
