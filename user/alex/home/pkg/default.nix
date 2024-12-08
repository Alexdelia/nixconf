{pkgs, ...}: {
  imports = [
    ./mime.nix

    ./git

    ## shell essentials
    ./bat.nix
    ./eza.nix
    ./zoxide.nix
    ./direnv.nix

    ## keyboard remapping
    # ./kanata
  ];

  home.packages = with pkgs; [
    ## shell essentials
    ### rust
    ripgrep
    xcp
    sd
    dysk
    typos
    tealdeer
    numbat
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
