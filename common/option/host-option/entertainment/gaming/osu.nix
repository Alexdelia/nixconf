{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.hostOption.entertainment.gaming {
    home.packages = with pkgs; [
      osu-lazer-bin
    ];
  };
}
