{ username }: { pkgs, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Alexandre Delille";
    extraGroups = [ "networkmanager" "wheel" ];

    shell = pkgs.nushell;
  };
}
