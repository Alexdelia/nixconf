{pkgs, ...}: let
  infoHub =
    pkgs.writers.writeBashBin "info-hub" {}
    /*
    bash
    */
    ''
      # eww open --toggle info_hub
      eww -c ~/.nc/user/alex/home/de/eww/src/ open --toggle info_hub
    '';
in {
  home.packages = [
    infoHub
  ];

  dp.infoHub = infoHub;

  programs.eww = {
    enable = true;

    package = pkgs.eww-wayland;

    configDir = ./src;
  };
}
