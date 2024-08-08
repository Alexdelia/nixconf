{pkgs, ...}: {
  imports = [
    ./git

    ## shell essentials
    ./eza.nix
    ./zoxide.nix

    ## nix
    ./nh.nix
  ];

  home.packages = with pkgs; [
    # neofetch

    ## shell essentials
    ripgrep
    typos

    ## nix
    nix-output-monitor
    alejandra
  ];
}
