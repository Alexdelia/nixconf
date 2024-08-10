{
  username,
  inputs,
  stateVersion,
}: {config, ...}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit inputs;
      scheme = config.scheme;
    };

    users.${username} = (
      (import ./home {})
      // (import ../../common/mkHome.nix {
        inherit username;
        inherit stateVersion;
        isNixos = true;
      })
    );
  };
}
