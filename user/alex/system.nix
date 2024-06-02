{ username, ... }: { pkgs, lib, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Alexandre Delille";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
