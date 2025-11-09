{config, ...}: {
  imports = [
    ./font.nix
    ./keybind.nix
    # ./touchpad.nix
    ./window-manager.nix
    ./panel.nix
    ./screenlocker.nix
  ];

  programs = {
    plasma = {
      enable = true;

      resetFiles = [
        # "${config.home.homeDirectory}/.gtkrc-2.0"
      ];

      workspace = {
        enableMiddleClickPaste = false;

        # colorScheme = "Breeze Dark";
        cursor = {
          theme = config.stylix.cursor.name;
          size = 24;
        };
        iconTheme = config.gtk.iconTheme.name;
        splashScreen.theme = "a2n.kuro";

        wallpaper = "${config.home.homeDirectory}/Pictures/wallpaper.png";
      };
    };
  };

  home.packages = [
    config.stylix.cursor.package
    config.gtk.iconTheme.package
  ];
}
