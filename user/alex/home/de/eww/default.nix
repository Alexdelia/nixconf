{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  eww = inputs.eww.packages.${pkgs.system}.eww;

  open = "eww open --toggle";
  # open = "eww -c ~/.nc/user/alex/home/de/eww/src/ open --toggle";

  widget =
    name: target:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ eww ];
      text = "${open} ${target}";
    };

  infoHub = widget "info-hub" "info_hub";

  powerMenu = widget "power-menu" "power_menu";
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

      package = eww;

      configDir = ./src;
    };
  };
}
