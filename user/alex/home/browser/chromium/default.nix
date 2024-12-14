{pkgs, ...}: {
  imports = [
    ./extension
  ];

  programs.chromium = {
    enable = true;

    package = pkgs.brave;
  };
}
