{scheme}:
with scheme.withHashtag; let
  back_primary = "#524554";
in {
  colors = {
    normal = {
      black = base10;
      red = base08;
      green = base0B;
      yellow = base0A;
      blue = base0D;
      magenta = base0E;
      cyan = base0C;
      white = base06; # not base05 on purpose;
    };

    bright = {
      black = base04;
      red = base12;
      green = base14;
      yellow = base13;
      blue = base16;
      magenta = base17;
      cyan = base15;
      white = base07;
    };

    cursor = {
      cursor = back_primary;
      text = base00;
    };

    primary = {
      background = base00;
      foreground = base05;
      bright_foreground = base07;
    };

    selection = {
      background = back_primary;
      text = base05;
    };

    # url_color = base0D;
    #
    # active_border_color = base00;
    # active_tab_background = base00;
    # active_tab_foreground = base05;
    #
    # inactive_border_color = base02;
    # inactive_tab_background = base02;
    # inactive_tab_foreground = base05;
    #
    # tab_bar_background = base00;
  };
}
