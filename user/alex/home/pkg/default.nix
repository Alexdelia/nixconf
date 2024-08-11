{pkgs, ...}: {
  imports = [
    ./git

    ## shell essentials
    ./eza.nix
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    # neofetch

    ## shell essentials
    ### rust
    ripgrep
    typos
    oxker
    ### rest
    wget # `ruget` is slower and less maintained

    ## nix
    nh
    nil
    nix-output-monitor
    alejandra
  ];
}
