{
  config,
  lib,
  scheme ? { },
  ...
}:
let
  s = (config.scheme or scheme).withHashtag;

  mode = import ./mode.nix;

  primary = lib.filterAttrs (_: m: m.primary) config.hostOption.spec.monitor;
  primaryWidth = if primary == { } then 1920 else (lib.head (lib.attrValues primary)).width;
in
{
  services.mako = {
    enable = true;

    settings = {
      anchor = "bottom-right";

      background-color = "${s.base00}ab";
      border-color = "${s.base0D}80";
      border-radius = 15;
      border-size = 3;
      # progress-color = "source ${s.base0D}00";

      font = "monospace 16";
      icons = true;

      margin = "10";
      padding = "3";
      width = builtins.floor (primaryWidth * 7 / 24);

      default-timeout = 5 * 1000; # ms

      max-history = 100;

      "outer-margin" = "0,5,20,0";

      "mode=${mode.dnd}" = {
        invisible = true;
      };

      "urgency=low" = {
        border-color = "${s.base04}80";
      };
      "urgency=normal" = {
        border-color = "${s.base0D}80";
      };
      "urgency=high" = {
        border-color = "${s.base08}80";
      };
    };
  };

  stylix.targets.mako.enable = false;
}
