{
  pkgs,
  config,
  lib,
  ...
}: let
  src = pkgs.unstable;
in {
  config = lib.mkIf config.hostOption.entertainment.video {
    home.packages = with src; [
      ani-cli
      (import ./ani.nix {pkgs = src;})
      (import ./ani.nix {
        pkgs = src;
        dubbed = true;
      })
    ];
  };
}
