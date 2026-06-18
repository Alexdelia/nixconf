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
    virtualisation.waydroid.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];
  };
}
