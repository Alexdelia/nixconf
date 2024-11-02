{
  pkgs,
  config,
  ...
}: let
  sway-conf = pkgs.writeText "sway-gtkgreet-config" ''
    exec "${config.programs.regreet.package}/bin/regreet; ${config.programs.sway.package}/bin/swaymsg exit"
    include /etc/sway/config.d/*
  '';
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${config.programs.sway.package}/bin/sway --config ${sway-conf}";
      };
    };
  };

  programs.regreet = {
    enable = true;
  };
}
