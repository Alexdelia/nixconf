{pkgs, ...}: {
  home.packages = [
    (pkgs.nerdfonts.override {fonts = ["RobotoMono" "SourceCodePro"];})
    # maple-mono
  ];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = ["RobotoMono Nerd Font"];

      serif = ["RobotoMono Nerd Font"];
      sansSerif = ["RobotoMono Nerd Font"];
    };
  };
}
