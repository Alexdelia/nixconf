{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.hostOption.type == "full") {
    programs.dconf = {
      enable = true;

      profiles.user.databases = let
        openInTerm = "alacritty -e";
      in [
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
              # calculator = ["<Super>k"];
              # media = ["<Super>m"]; # media player

              screensaver = [""];
            };

            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = [
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
              ];
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
              name = "alacritty";
              command = "alacritty";
              binding = "<Super>c";
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
              name = "music player";
              command = "${openInTerm} rmpc";
              binding = "<Super>m";
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
              name = "calculator";
              command = "${openInTerm} numbat";
              binding = "<Super>k";
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
              name = "ssh fuzzy";
              command = "${openInTerm} ssh-fuzzy";
              binding = "<Super>j";
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

            "org/gnome/shell/keybindings" = {
              "show-screenshot-ui" = ["<Super>Print" "<Super>s"];
              "toggle-quick-settings" = [""];
            };
          };
        }
      ];
    };
  };
}
