{inputs}: {
  mkNixosConfigurations = import ./mkNixosConfigurations.nix {
    inherit inputs;
  };
  mkHomeConfigurations = import ./mkHomeConfigurations.nix {
    nixpkgs = inputs.nixpkgs;
    home-manager = inputs.home-manager;
  };
}
