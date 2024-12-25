{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.hostOption.entertainment.music {
    home.packages = [
      pkgs.mpc
    ];
  };
}
