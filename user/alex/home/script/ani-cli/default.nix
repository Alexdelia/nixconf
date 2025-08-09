{pkgs, ...}: {
  home.packages = [
    (import ./ani.nix {inherit pkgs;})
    (import ./ani.nix {
      inherit pkgs;
      dubbed = true;
    })
  ];
}
