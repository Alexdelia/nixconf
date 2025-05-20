{pkgs, ...}: {
  home.packages =
    (with pkgs.nerd-fonts; [
      roboto-mono
      sauce-code-pro
    ])
    ++ (with pkgs; [
      maple-mono
    ]);

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      monospace = ["RobotoMono Nerd Font"];

      serif = ["RobotoMono Nerd Font"];
      sansSerif = ["RobotoMono Nerd Font"];
    };
  };
}
