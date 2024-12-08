{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.hostOption.entertainment.gaming {
    environment.systemPackages = with pkgs; [
      osu-lazer-bin
    ];
  };
}
