{
  pkgs,
  config,
  lib,
  users,
  ...
}: let
  enable =
    config.hostOption.entertainment.gaming
    && config.hostOption.type == "full";
in {
  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      android-studio
      android-tools # adb
      steam-run
    ];

    users.extraGroups.kvm.members = users;
  };
}
