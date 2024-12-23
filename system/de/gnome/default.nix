{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.hostOption.type == "full") {
    services.xserver = {
      enable = true;

      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    environment.gnome.excludePackages = with pkgs; [
      gedit # text editor

      cheese # webcam tool
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player
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

    programs.dconf = {
      enable = true;

      profiles.user.databases = [
        {
          lockAll = true; # prevents overriding

          settings = {
            "org/gnome/desktop/wm/preferences" = {
              num-workspaces = lib.gvariant.mkInt32 10;
            };
            "org/gnome/shell/app-switcher" = {
              current-workspace-only = true;
            };

            "org/gnome/desktop/search-providers" = {
              disabled = [
                "org.gnome.Nautilus.desktop"
                "org.gnome.Calendar.desktop"
                "org.gnome.clocks.desktop"
                "org.gnome.seahorse.Application.desktop"
                "org.gnome.Contacts.desktop"
              ];
            };

            ## shortcut
            "org/gnome/settings-daemon/plugins/media-keys" = {
              www = ["<Super>b"];
              calculator = ["<Super>k"];
            };
            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = [
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
              ];
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
              binding = "<Super>c";
              command = "alacritty";
              name = "alacritty";
            };
            "org/gnome/desktop/wm/keybindings" = {
              "switch-to-workspace-1" = ["<Super>1"];
              "switch-to-workspace-2" = ["<Super>2"];
              "switch-to-workspace-3" = ["<Super>3"];
              "switch-to-workspace-4" = ["<Super>4"];
              "switch-to-workspace-5" = ["<Super>5"];
              "switch-to-workspace-6" = ["<Super>6"];
              "switch-to-workspace-7" = ["<Super>7"];
              "switch-to-workspace-8" = ["<Super>8"];
              "switch-to-workspace-9" = ["<Super>9"];
              "switch-to-workspace-10" = ["<Super>0"];

              "switch-windows" = ["<Alt>Tab"];
              "switch-windows-backward" = ["<Shift><Alt>Tab"];
              "switch-applications" = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
              "switch-applications-backward" = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            };
          };
        }
      ];
    };
  };
}
