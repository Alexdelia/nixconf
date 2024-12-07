{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.entertainment.video {
    home.packages = with pkgs; [
      ani-cli
    ];
  };
}
