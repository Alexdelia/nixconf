{
  config,
  scheme ? {},
  ...
}: let
  s = (config.scheme or scheme).withHashtag;
in {
  services.mako = {
    enable = true;

    anchor = "bottom-right";

    backgroundColor = "${s.base00}ab";
    borderColor = "${s.base0E}80";
    borderRadius = 15;
    borderSize = 3;
    # progressColor = "source ${s.base0D}00";

    font = "monospace 16";
    icons = true;

    margin = "10";
    padding = "3";
    width = null;

    defaultTimeout = 5 * 1000; # ms

    extraConfig = ''
      outer-margin=0,5,20,0

      [urgency=low]
      border-color=${s.base04}80

      [urgency=normal]
      border-color=${s.base0E}80

      [urgency=high]
      border-color=${s.base08}80
      default-timeout=0
    '';
  };

  stylix.targets.mako.enable = false;
}
