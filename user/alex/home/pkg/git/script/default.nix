{ pkgs, ... }:
[
  (import ./ga.nix { inherit pkgs; })
  (import ./gap.nix { inherit pkgs; })
  (import ./grs.nix { inherit pkgs; })
  (import ./gdl.nix { inherit pkgs; })
  (import ./gtv.nix { inherit pkgs; })
]
++ (import ./git-identity.nix { inherit pkgs; })
