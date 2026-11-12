{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = config.home.username;

  unit = import ../../../../common/package/keyheat/unit.nix {
    inherit lib user;
    inherit (pkgs) keyheat;
    host = "work";
    keymap = {
      rules = "evdev";
      model = "pc105";
      layout = "fr";
      variant = "us";
      options = lib.concatStringsSep "," config.programs.plasma.input.keyboard.options;
    };
  };

  renderValue =
    value:
    if lib.isList value then
      lib.concatStringsSep " " value
    else if lib.isBool value then
      lib.boolToString value
    else
      toString value;

  unitFile = pkgs.writeText "keyheat.service" ''
    [Unit]
    Description=keyheat typing statistics
    After=systemd-logind.service

    [Service]
    ExecStart=${unit.execStart}
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: "${name}=${renderValue value}") unit.serviceConfig
    )}

    [Install]
    WantedBy=multi-user.target
  '';

  udevRuleFile = pkgs.writeText "99-keyheat.rules" ''
    ${unit.udevRule}
  '';

  keyheatInstall = pkgs.writeShellApplication {
    name = "keyheat-install";
    runtimeEnv = {
      KEYHEAT_USER = user;
      KEYHEAT_UNIT = unitFile;
      KEYHEAT_UDEV_RULE = udevRuleFile;
    };
    text = builtins.readFile ./keyheat-install.sh;
  };
in
{
  config = lib.mkIf (config.hostOption.keyheat && config.targets.genericLinux.enable) {
    home.packages = [ keyheatInstall ];
  };
}
