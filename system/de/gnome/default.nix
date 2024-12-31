{
  config,
  lib,
  ...
}: {
  imports = [
    ./dconf.nix
    ./exclude.nix
  ];

  config = lib.mkIf (config.hostOption.type == "full") {
    hostOption.spec.wlroots = false;

    services.xserver = {
      enable = true;

      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    stylix.enable = true;
  };
}
