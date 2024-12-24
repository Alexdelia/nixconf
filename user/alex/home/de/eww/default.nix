{pkgs, ...}: {
  dp.infoHub =
    pkgs.writers.writeBashBin "info-hub" {}
    /*
    bash
    */
    ''
      # eww open --toggle info_hub
      eww -c ${./src} open --toggle info_hub
    '';

  programs.eww = {
    enable = true;

    configDir = ./src;
  };
}
