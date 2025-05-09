{pkgs, ...}:
[
  (import ./ga.nix {inherit pkgs;})
  (import ./grs.nix {inherit pkgs;})
  (import ./gcv.nix {inherit pkgs;})
]
++ (import ./git-identity {inherit pkgs;})
