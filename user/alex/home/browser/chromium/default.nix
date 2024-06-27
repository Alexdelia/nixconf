{pkgs, ...}: {
  programs.chromium = {
    enable = true;

    package = pkgs.brave;

    # extensions = builtins.trace import ./extension;
  };
}
