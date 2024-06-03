{ username, home-manager, ... }: { config, pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.${username} = {
    imports = [
      ./pkg
      ./shell
    ];

    home = {
      username = username;
      homeDirectory = "/home/${username}";

      stateVersion = "24.05";
    };

    programs.home-manager.enable = true;
  };
}
