{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git
    ./eza.nix
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    # neofetch

    ## shell essentials
    ripgrep
    typos

    ## tty
    warp-terminal

    ## nix
    alejandra
  ];
}
