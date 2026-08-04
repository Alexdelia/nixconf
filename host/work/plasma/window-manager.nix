let
  role = import ../../../user/alex/home/de/sway/role.nix;
in
{
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
}
