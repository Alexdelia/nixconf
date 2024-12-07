{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.entertainment.gaming {
    programs.steam = {
      enable = true;

      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = false;

      # translate X11 input events to uinput events (e.g. for using Steam Input on Wayland)
      extest.enable = true;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}
