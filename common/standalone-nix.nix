{ pkgs, ... }:
{
  nix = {
    package = pkgs.nix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      max-jobs = 4;
    };
  };
}
