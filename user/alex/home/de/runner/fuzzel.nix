{
  pkgs,
  config,
  scheme ? {},
  ...
}: let
  s = config.scheme or scheme;
in {
  dp.dmenu = "${pkgs.fuzzel}/bin/fuzzel";

  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        terminal = config.dp.term;
        layer = "overlay";

        # font = "SauceCodeProNerdFont:size=36";
        font = "RobotoMono Nerd Font Mono:size=36";

        prompt = ''"  "'';

        anchor = "top";

        y-margin = 300;
        width = 40;
        lines = 8;

        horizontal-pad = 24;
        vertical-pad = 20;
        inner-pad = 12;
      };

      border = {
        width = 0;
        radius = 20;
        selection-radius = 8;
      };

      colors = {
        background = "${s.base00}f5";
        text = "${s.base05}ff";
        prompt = "${s.base05}30";
        match = "${s.base0B}ff";
        selection = "${s.base0B}40";
        selection-text = "${s.base05}ff";
        selection-match = "${s.base0B}ff";
        # border = "${s.base0D}80";
      };
    };
  };

  stylix.targets.fuzzel.enable = false;
}
