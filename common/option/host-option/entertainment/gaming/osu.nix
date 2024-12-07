{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.entertainment.gaming {
    environment.systemPackages = with pkgs; [
      osu-lazer-bin
    ];
  };
}
