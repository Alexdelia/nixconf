{pkgs, ...}: {
  home.packages = [
    (import ./nr.nix {inherit pkgs;})
    (import ./ns.nix {inherit pkgs;})
  ];
}
