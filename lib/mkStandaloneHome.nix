{
  nixpkgs,
  home-manager,
}: (
  {
    username,
    system,
    stateVersion,
  }: {
    ${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};

      modules = [
        (import ./mkHome.nix {
          inherit username stateVersion;
          isNixos = false;
        })
        ../user/${username}/home
      ];
    };
  }
)
