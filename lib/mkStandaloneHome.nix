{
  nixpkgs,
  home-manager,
}: {
  username,
  system,
  stateVersion,
}: {
  ${username} = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackagees.${system};

    modules = [
      (./mkHome.nix {
        inherit username stateVersion;
        isNixos = false;
      })
      ./user/${username}/home
    ];
  };
}
