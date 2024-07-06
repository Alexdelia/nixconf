{pkgs, ...}: {
  home.packages = [
    (pkgs.nerdfonts.override {fonts = ["RobotoMono" "SourceCodePro"];})
  ];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = ["RobotoMono"];

      serif = ["RobotoMono"];
      sansSerif = ["RobotoMono"];
    };
  };
}
