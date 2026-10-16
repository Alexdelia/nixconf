{
  config,
  lib,
  ...
}:
let
  c = config.scheme.withHashtag;

  floatingPadding = 16;

  floatingHeader = lib.mapAttrs (_: lib.mkForce) {
    border = c.base01;
    background = c.base01;
    text = c.base05;
    indicator = c.base01;
    childBorder = c.base00;
  };
in
{
  wayland.windowManager.sway = {
    config = {
      window = {
        border = 0;
        hideEdgeBorders = "both";
        titlebar = false;
      };

      floating = {
        border = floatingPadding;
        titlebar = true;
      };

      colors = {
        focused = floatingHeader;
        focusedInactive = floatingHeader;
        unfocused = floatingHeader;
      };
    };

    extraConfig = ''
      titlebar_border_thickness 0
      titlebar_padding 12 8
    '';
  };
}
