{
  pkgs,
  config,
  lib,
  ...
}: let
  enable =
    config.hostOption.entertainment.gaming
    && config.hostOption.type == "full";
in {
  config = lib.mkIf enable {
    programs.lutris.enable = true;

    home.packages = with pkgs; [
      wine
    ];
  };
}
