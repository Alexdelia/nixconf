{pkgs, ...}: {
  imports = [
    ./git

    ## shell essentials
    ./bat.nix
    ./eza.nix
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    # neofetch

    ## shell essentials
    ### rust
    ripgrep
    typos
    tealdeer
    oxker
    skim
    jaq
    ### rest
    wget # `ruget` is slower and less maintained

    ## nix
    nh
    nil
    nix-output-monitor
    alejandra
  ];
}
