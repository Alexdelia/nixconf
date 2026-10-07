{ username }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hostOption) vault;
  user = config.users.users.${username};
  usbMount = "/media/usb";
in
{
  config = lib.mkIf (vault != null) {
    fileSystems.${usbMount} = {
      device = "/dev/disk/by-uuid/${vault.usb}";
      fsType = "vfat";
      options = [
        "noauto"
        "user"
        "umask=0077"
        "flush"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${usbMount} 0755 root root -"
      "d ${vault.hdd} 0700 ${username} ${user.group} -"
    ];

    users.users.${username}.packages = [
      (import ./script.nix {
        inherit pkgs vault usbMount;
        inherit (user) home;
        inherit (config.security) wrapperDir;
      })
    ];
  };
}
