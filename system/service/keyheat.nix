{
  config,
  lib,
  pkgs,
  hostname,
  users,
  ...
}:
let
  unit = import ../../common/package/keyheat/unit.nix {
    inherit lib;
    inherit (pkgs) keyheat;
    host = hostname;
    user = builtins.head users;
    keymap = {
      rules = "evdev";
      model = "pc105";
      inherit (config.services.xserver.xkb) layout variant;
      options = "caps:backspace,custom:no_backspace";
    };
  };
in
{
  config = lib.mkIf config.hostOption.keyheat {
    users = {
      users.keyheat = {
        isSystemUser = true;
        group = "keyheat";
      };

      groups.keyheat.members = users;
    };

    systemd.services.keyheat = {
      description = "keyheat typing statistics";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-logind.service" ];
      serviceConfig = unit.serviceConfig // {
        ExecStart = unit.execStart;
      };
    };

    services.udev.extraRules = unit.udevRule;
  };
}
