{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./dconf.nix
    ./exclude.nix
  ];

  config = lib.mkIf (config.hostOption.type == "full") {
    hostOption.spec.wlroots = false;

    services = {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
    };

    stylix.enable = true;

    environment.systemPackages = with pkgs; [
      gnomeExtensions.fullscreen-notifications
      gnomeExtensions.impatience
    ];
  };
}
