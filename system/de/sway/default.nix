{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./greet
  ];

  config = lib.mkIf (config.hostOption.type == "minimal") {
    environment.systemPackages = with pkgs; [
      grim
      slurp
      wl-clipboard
      mako
    ];

    services.gnome.gnome-keyring.enable = true;

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };
}
