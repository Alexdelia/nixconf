{
  pkgs,
  config,
  ...
}: {
  dp = {
    clipboard-copy = "${pkgs.wl-clipboard-rs}/bin/wl-copy";
    clipboard-paste = "${pkgs.wl-clipboard-rs}/bin/wl-paste";
  };

  imports = [
    ../../../../common/option

    ./mime.nix

    ## shell essentials
    ./git
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

    ## non-free
    slack
  ];
  # ++ (
  # if config.hostOption.type == "full"
  # then [
  # libreoffice-still
  # ]
  # else []
  # );
}
