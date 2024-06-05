{ config, pkgs, nixpkgs-unstable, ... }:

{
  # imports = [];

  programs.warp-terminal = {
    enable = true;
    package = nixpkgs-unstable.warp-terminal;
  };

  home.packages = with pkgs; [
    neofetch
  ];
}
