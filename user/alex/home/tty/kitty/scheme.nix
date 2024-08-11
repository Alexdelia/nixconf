{scheme}:
with scheme.withHashtag; let
  back_primary = "#524554";
in {
  # normal (ansi 30-37)
  color0 = base10; # black
  color1 = base08; # red
  color2 = base0B; # green
  color3 = base0A; # yellow
  color4 = base0D; # blue
  color5 = base0E; # magenta
  color6 = base0C; # cyan
  color7 = base06; # white  # not base05 on purpose

  # bright (ansi 90-97)
  color8 = base11; # black
  color9 = base12; # red
  color10 = base14; # green
  color11 = base13; # yellow
  color12 = base16; # blue
  color13 = base17; # magenta
  color14 = base15; # cyan
  color15 = base07; # white

  cursor = back_primary;

  background = base00;
  foreground = base05;

  selection_background = back_primary;
  selection_foreground = base05;

  url_color = base0D;

  active_border_color = base00;
  active_tab_background = base00;
  active_tab_foreground = base05;

  inactive_border_color = base02;
  inactive_tab_background = base02;
  inactive_tab_foreground = base05;

  tab_bar_background = base00;
}
