{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  open = "eww open --toggle";
  # open = "eww -c ~/.nc/user/alex/home/de/eww/src/ open --toggle";

  infoHub = pkgs.writers.writeBashBin "info-hub" { } "${open} info_hub";

  powerMenu = pkgs.writers.writeBashBin "power-menu" { } "${open} power_menu";
in
{
  config = lib.mkIf (config.hostOption.type == "lite" && pkgs.system != "aarch64-linux") {
    home.packages = [
      infoHub
      powerMenu
    ];

    dp.infoHub = "${infoHub}/bin/info-hub";
    dp.powerMenu = "${powerMenu}/bin/power-menu";

    programs.eww = {
      enable = true;

      package = inputs.eww.packages.${pkgs.system}.eww;

      configDir = ./src;
    };
  };
}
