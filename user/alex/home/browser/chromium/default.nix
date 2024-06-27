{pkgs, ...}: {
  programs.chromium = {
    enable = true;

    package = pkgs.brave;

    extensions = import ./extension;
  };
}
