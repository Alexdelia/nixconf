{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.hostOption.entertainment.video {
    home.packages = with pkgs; [
      ani-cli
      (import ./ani.nix {inherit pkgs;})
      (import ./ani.nix {
        inherit pkgs;
        dubbed = true;
      })
    ];
  };
}
