{
  username,
  inputs,
  stateVersion,
}: {
  config,
  lib,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit inputs;
      scheme = config.scheme;
    };

    users.${username} = (
      (import ./home {inherit lib;})
      // (import ../../common/mkHome.nix {
        inherit username;
        inherit stateVersion;
        isNixos = true;
      })
    );
  };
}
