{
  config,
  pkgs,
  ...
}: {
  programs.plasma.hotkeys = {
    commands = {
      alacritty = {
        comment = "launch alacritty terminal";
        command = "${config.home.homeDirectory}/.cargo/bin/alacritty";
        key = "Meta+C";
      };

      chromium = {
        comment = "launch chromium browser";
        command = "chromium";
        key = "Meta+B";
      };

      anyrun = {
        comment = "launch anyrun dmenu";
        command = "${pkgs.anyrun}/bin/anyrun";
        key = "Meta+D";
      };
    };
  };
}
