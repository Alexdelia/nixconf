{ pkgs, lib, ... }:
let
  username = "alex";
in {
  users.users.${username} = {
    isNormalUser = true;
    description = "Alexandre Delille";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
