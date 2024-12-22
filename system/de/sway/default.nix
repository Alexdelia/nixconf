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
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    environment.systemPackages = with pkgs; [
      grim
      slurp
      wl-clipboard-rs
      mako
    ];

    services.gnome.gnome-keyring.enable = true;
  };
}
