{inputs}: {
  mkStandaloneHome = import ./mkStandaloneHome.nix {
    nixpkgs = inputs.nixpkgs;
    home-manager = inputs.home-manager;
  };
}
