{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.hostOption.entertainment.gaming {
    /*
    home.packages = with pkgs.unstable; [
      osu-lazer-bin
    ];
    */
    environment.systemPackages = with pkgs.unstable; [
      osu-lazer-bin
    ];
  };
}
