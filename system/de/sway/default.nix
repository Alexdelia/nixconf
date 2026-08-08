{
  pkgs,
  ...
}:
{
  imports = [
    ./greet
  ];

  config = {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;

      extraPackages = with pkgs; [
        brightnessctl
        pulseaudio
        # mako
      ];
    };

    services.gnome.gnome-keyring.enable = true;

    stylix = {
      enable = true;

      /*
        targets = {
          sway.enable = true;
          swaylock.enable = false;
        };
      */
    };
  };
}
