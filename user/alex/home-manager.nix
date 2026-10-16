{
  username,
  inputs,
  stateVersion,
}:
{ config, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops

      inputs.base16.homeManagerModule
      { inherit (config) scheme; }
    ];

    extraSpecialArgs = {
      inherit inputs;
      inherit username;
    };

    users.${username} =
      (import ./home { })
      // (import ../../common/mkHome.nix {
        inherit username;
        inherit stateVersion;
        isNixos = true;
        inherit (config) hostOption;
      });
  };
}
