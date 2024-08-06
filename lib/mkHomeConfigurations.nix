{
  nixpkgs,
  home-manager,
}: (
  {
    system,
    users,
    stateVersion,
  }: {
    homeConfigurations = builtins.listToAttrs (
      map
      (username: {
        name = username;
        value = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};

          modules = [
            (import ../user/${username}/home/mkHome.nix {
              inherit username stateVersion;
              isNixos = false;
            })
            ../user/${username}/home
          ];
        };
      })
      users
    );
  }
)
