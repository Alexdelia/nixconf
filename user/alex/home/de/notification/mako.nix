{
  config,
  lib,
  scheme ? {},
  ...
}: let
  s = (config.scheme or scheme).withHashtag;

  primary = lib.filterAttrs (_: m: m.primary) config.hostOption.spec.monitor;
  primaryWidth =
    if primary == {}
    then 1920
    else (lib.head (lib.attrValues primary)).width;
in {
  services.mako = {
    enable = true;

    settings = {
      anchor = "bottom-right";

      backgroundColor = "${s.base00}ab";
      borderColor = "${s.base0D}80";
      borderRadius = 15;
      borderSize = 3;
      # progressColor = "source ${s.base0D}00";

      font = "monospace 16";
      icons = true;

      margin = "10";
      padding = "3";
      width = builtins.floor (primaryWidth * 7 / 24);

      defaultTimeout = 5 * 1000; # ms

      "outer-margin" = "0,5,20,0";

      "urgency=low" = {
        borderColor = "${s.base04}80";
      };
      "urgency=normal" = {
        borderColor = "${s.base0D}80";
      };
      "urgency=high" = {
        borderColor = "${s.base08}80";
      };
    };
  };

  stylix.targets.mako.enable = false;
}
