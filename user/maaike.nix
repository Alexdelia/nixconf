{
  pkgs,
  lib,
  ...
}: let
  username = "maaike";
in {
  users.users.${username} = {
    isNormalUser = true;
    description = "Maaike Sloot";
    extraGroups = ["networkmanager" "wheel"];
  };
}
