{pkgs, ...}: {
  home.packages = [
    (import ./ns.nix {inherit pkgs;})
    (import ./nr.nix {inherit pkgs;})
  ];
}
