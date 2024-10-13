{pkgs, ...}: {
  imports = [
    ./git

    ## shell essentials
    ./bat.nix
    ./eza.nix
    ./zoxide.nix

    ## keyboard remapping
    # ./kanata
  ];

  home.packages = with pkgs; [
    ## shell essentials
    ### rust
    ripgrep
    xcp
    dysk
    typos
    tealdeer
    ouch
    oxker
    skim
    jaq
    ### rest
    wget # `ruget` is slower and less maintained
    wl-clipboard # dependency of a lot of tools

    ## nix
    nh
    nil
    nix-output-monitor
    alejandra

    ## work-related
    libreoffice-qt-still

    ## non-free
    slack
  ];
}
