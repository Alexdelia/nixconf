{
  inputs,
  pkgs,
  ...
}: {
  stylix = {
    enable = true;

    image = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/o3/wallhaven-o31o2p.png";
      sha256 = "sha256-KMTq1cvtV2jd+hOCBxkMWN1nZDllH9aWotqO3i0tcaw=";
    };

    polarity = "dark";

    base16Scheme = "${inputs.vity-base24}/vity.yaml";

    fonts = let
      mono = {
        package = pkgs.nerdfonts.override {fonts = ["SourceCodePro"];};
        name = "SourceCodePro Nerd Font";
      };
      rest = {
        package = pkgs.nerdfonts.override {fonts = ["RobotoMono"];};
        name = "RobotoMono Nerd Font";
      };
    in {
      monospace = mono;

      serif = rest;
      sansSerif = rest;
      emoji = rest;

      sizes = {
        applications = 14;
        desktop = 14;
        popups = 14;
        terminal = 16;
      };
    };

    cursor = {
      package = pkgs.vimix-cursor-theme;
      name = "Vimix-Cursors-White";
      # size =
    };
  };
}
