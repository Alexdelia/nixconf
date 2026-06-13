{pkgs, ...}: let
  shell = import ./shell.nix {inherit pkgs;};
in {
  home.packages = [
    (import ./nr.nix {inherit pkgs;})

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
