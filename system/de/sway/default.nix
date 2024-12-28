{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./greet
  ];

  config = lib.mkIf (config.hostOption.type == "lite" || config.hostOption.type == "minimal") {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    environment.systemPackages = with pkgs; [
      mako
    ];

    services.gnome.gnome-keyring.enable = true;
  };
}
