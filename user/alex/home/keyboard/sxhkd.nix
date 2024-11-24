{
  # config,
  pkgs,
  ...
}: {
  services.sxhkd = {
    enable = true;

    keybindings = let
      playerctl = "${pkgs.playerctl}/bin/playerctl";
    in {
      # apps
      # "super + c" = config.dp.term;
      # "super + b" = config.dp.browser;
      # "super + m" = config.dp.music;
      # "super + k" = config.dp.calculator;
      # "super + f" = config.dp.fileManager;

      # screen read
      # "super + s" = "screenshot";
      # "super + q" = "colorpicker";

      # sound
      "super + z" = "${playerctl} play-pause";
      "super + x" = "${playerctl} next";
    };
  };
}
