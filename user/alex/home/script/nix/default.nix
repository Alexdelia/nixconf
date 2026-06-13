{pkgs, ...}: {
  home.packages = [
    (import ./nr.nix {inherit pkgs;})
    (import ./ns.nix {inherit pkgs;})
    (import ./nus.nix {inherit pkgs;})
    (import ./nsu.nix {inherit pkgs;})
    (import ./nusu.nix {inherit pkgs;})
  ];
}
