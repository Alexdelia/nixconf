{
  inputs,
  pkgs,
  ...
}: let
  open = "eww open --toggle";
  # open = "eww -c ~/.nc/user/alex/home/de/eww/src/ open --toggle";

  infoHub =
    pkgs.writers.writeBashBin "info-hub" {} "${open} info_hub";

  powermenu =
    pkgs.writers.writeBashBin "powermenu" {} "${open} powermenu";
in {
  home.packages = [
    infoHub
    powermenu
  ];

  dp.infoHub = "${infoHub}/bin/info-hub";
  dp.powermenu = "${powermenu}/bin/powermenu";

  programs.eww = {
    enable = true;

    package = inputs.eww.packages.${pkgs.system}.eww;

    configDir = ./src;
  };
}
