{inputs}: {
  mkStandaloneHome = import ./mkStandaloneHome.nix {home-manager = inputs.home-manager;};
}
