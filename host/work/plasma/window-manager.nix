let
  role = import ../../../user/alex/home/de/sway/role.nix;
in {
  programs.plasma.kwin = {
    borderlessMaximizedWindows = true;

    effects = {
      desktopSwitching.animation = "off";
      minimization.animation = "off";
      windowOpenClose.animation = "off";
    };

    nightLight = {
      time = {
        morning = "09:00";
        evening = "18:00";
      };
      transitionTime = 30; # in minutes
      temperature = {
        day = 6500;
        night = 4500;
      };
    };

    virtualDesktops = {
      number = builtins.length role.list;
      names = role.list;
    };
  };

  programs.plasma.window-rules = [
    {
      description = "singleton: slack";
      match.window-class = {
        value = "Slack";
        type = "exact";
      };
      apply = {
        desktops = {
          value = "Desktop_9";
          apply = "force";
        };
        activity = {
          value = "";
          apply = "force";
        };
      };
    }
    {
      description = "singleton: brave";
      match.window-class = {
        value = "brave-browser";
        type = "exact";
      };
      apply = {
        desktops = {
          value = "Desktop_10";
          apply = "force";
        };
        activity = {
          value = "";
          apply = "force";
        };
      };
    }
  ];
}
