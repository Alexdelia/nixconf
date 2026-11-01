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
  usbRepo = "${usbMount}/vault";
  link = "${user.home}/vault";
  runtimeDirPattern = "/run/user/*";
in
{
  config = lib.mkIf (vault != null) {
    fileSystems.${usbMount} = {
      device = "/dev/disk/by-uuid/${vault.usb}";
      fsType = "ext4";
      options = [
        "noauto"
        "user"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${usbMount} 0755 root root -"
      "d ${vault.hdd} 0700 ${username} ${user.group} -"
    ];

    systemd.user.tmpfiles.users.${username}.rules = [
      "L ${link} - - - - %t/vault"
    ];

    home-manager.users.${username}.programs.git.includes =
      map
        (gitDir: {
          condition = "gitdir:${gitDir}/";
          contents = {
            core = {
              compression = 0;
              bigFileThreshold = "1m";
            };
            gc.auto = 0;
          };
        })
        [
          "${runtimeDirPattern}/vault"
          usbRepo
          "${runtimeDirPattern}/vault-hdd"
        ];

    users.users.${username}.packages = [
      (import ./script.nix {
        inherit
          pkgs
          vault
          usbMount
          usbRepo
          link
          ;
        inherit (user) home;
        inherit (config.security) wrapperDir;
      })
    ];
  };
}
