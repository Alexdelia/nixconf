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
    home.packages = with pkgs; [
      prismlauncher
    ];
  };
}
