{pkgs, ...}: {
  dp = {
    clipboard-copy = "${pkgs.wl-clipboard-rs}/bin/wl-copy";
    clipboard-paste = "${pkgs.wl-clipboard-rs}/bin/wl-paste";
  };

  imports = [
    ./mime.nix

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
    wl-clipboard-rs
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
