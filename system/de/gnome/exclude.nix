{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.hostOption.type == "full") {
    environment.gnome.excludePackages = with pkgs; [
      gedit # text editor

      cheese # webcam tool
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      papers # document viewer
      totem # video player
      showtime # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game

      baobab
      gnome-text-editor
      gnome-calculator
      gnome-calendar
      gnome-characters
      gnome-clocks
      gnome-console
      gnome-contacts
      gnome-font-viewer
      gnome-logs
      gnome-maps
      gnome-music
      gnome-system-monitor
      gnome-weather
      loupe
      # nautilus
      # gnome-connections
      simple-scan
      snapshot
      yelp

      gnome-backgrounds
      # gnome-bluetooth
      # gnome-color-manager
      # gnome-control-center
      gnome-tour
      gnome-user-docs
      # glib # for gsettings program
      # gnome-menus
      # gtk3.out # for gtk-launch program
      # xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
      # xdg-user-dirs-gtk # Used to create the default bookmarks

      gnome-online-accounts
      gnome-initial-setup
      gnome-remote-desktop
      gnome-shell
      gnome-shell-extensions
      gnome-user-share
    ];
  };
}
