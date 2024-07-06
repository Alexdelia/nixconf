{
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["RobotoMono" "Source Code Pro"];})
  ];
}
