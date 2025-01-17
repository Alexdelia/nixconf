{pkgs, ...}: {
  home.packages = [
    (import ./drm.nix {inherit pkgs;})
  ];
}
