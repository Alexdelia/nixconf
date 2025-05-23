{
  username,
  inputs,
  stateVersion,
}: {config, ...}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];

    extraSpecialArgs = {
      inherit inputs;
      inherit username;
      inherit (config) scheme;
    };

    users.${username} =
      (import ./home {})
      // (import ../../common/mkHome.nix {
        inherit username;
        inherit stateVersion;
        isNixos = true;
        inherit (config) hostOption;
      });
  };
}
