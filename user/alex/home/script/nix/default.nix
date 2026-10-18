{ pkgs, inputs, ... }:
let
  shell = import ./shell.nix { inherit pkgs; };
in
{
  imports = [
    ./completion.nix
  ];

  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
    nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
  };

  home.packages = [
    (import ./nr.nix { inherit pkgs; })

    (shell {
      name = "ns";
      argRequired = false;
    })
    (shell {
      name = "nsu";
      unfree = true;
    })
    (shell {
      name = "nus";
      unstable = true;
    })
    (shell {
      name = "nusu";
      unstable = true;
      unfree = true;
    })
  ];
}
