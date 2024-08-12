{pkgs, ...}: {
  home.packages = with pkgs; [
    bat-extras.batman
  ];

  programs.bat = {
    enable = true;
  };

  stylix.targets.bat.enable = false;
}
