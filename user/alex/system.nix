{ lib, /*username,*/ ... }:

{
  users.users./*${username}*/alex = {
    isNormalUser = true;
    description = "Alexandre Delille";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
