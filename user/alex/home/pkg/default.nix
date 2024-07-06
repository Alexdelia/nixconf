{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git
    ./eza.nix
  ];

  home.packages = with pkgs; [
    # neofetch

    ## shell essentials
    ripgrep

    ## tty
    warp-terminal

    ## nix
    alejandra
  ];
}
