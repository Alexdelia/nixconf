{
  services.pipewire = {
    enable = true;

    alsa = {
      enable = true;

      support32Bit = true;
    };

    pulse.enable = true;

    # pipewire 1.6.6 x11-bell segfaults when xwayland exits, restart drops every pulse client
    extraConfig.pipewire.no-x11-bell."context.properties"."module.x11.bell" = false;

    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;

    wireplumber.extraConfig = import ./wireplumber;
  };

  security.rtkit.enable = true;

  services.pulseaudio.enable = false;
}
