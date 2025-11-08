{
  lib,
  pkgs,
  config,
  ...
}: {
  stylix = {
    image = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/o3/wallhaven-o31o2p.png";
      sha256 = "sha256-KMTq1cvtV2jd+hOCBxkMWN1nZDllH9aWotqO3i0tcaw=";
    };

    polarity = "dark";

    base16Scheme = "${config.scheme}";

    fonts = let
      mono = {
        package = pkgs.nerd-fonts.sauce-code-pro;
        name = "SourceCodePro Nerd Font";
      };
      rest = {
        package = pkgs.nerd-fonts.roboto-mono;
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
      # package = pkgs.vimix-cursor-theme;
      # name = "Vimix-Cursors-White";

      package = pkgs.google-cursor;
      name = "GoogleDot-White";

      size = lib.mkDefault 16;
    };
  };
}
