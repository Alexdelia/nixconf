{pkgs, ...}: {
  home.packages =
    (with pkgs.nerd-fonts; [
      roboto-mono
      sauce-code-pro

      symbols-only
    ])
    ++ (with pkgs; [
      maple-mono.NL-TTF-AutoHint
    ]);

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = ["RobotoMono"];

      serif = ["RobotoMono"];
      sansSerif = ["RobotoMono"];
    };
  };
}
