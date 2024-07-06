{
  username,
  nixpkgs-unstable,
  home-manager,
  ...
}: {
  config,
  pkgs,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {inherit nixpkgs-unstable;};

    users.${username} = {
      imports = [
        ./pkg
        ./shell
        # ./tty
        ./editor
        ./browser
      ];

      home = {
        username = username;
        homeDirectory = "/home/${username}";

        stateVersion = "24.05";
      };

      programs.home-manager.enable = true;
    };
  };
}
