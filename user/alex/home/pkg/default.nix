{
  pkgs,
  config,
  ...
}: let
  clipboard =
    if config.hostOption.type == "full"
    then pkgs.wl-clipboard
    else pkgs.wl-clipboard-rs;
in {
  dp = {
    clipboard-copy = "${clipboard}/bin/wl-copy";
    clipboard-paste = "${clipboard}/bin/wl-paste";

    colorpicker = "${pkgs.hyprpicker}/bin/hyprpicker -a";
  };

  imports = [
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

  home.packages = with pkgs;
    [
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
      clipboard # if wlroots, use wl-clipboard-rs, else wl-clipboard
      wget # `ruget` is slower and less maintained

      ## nix
      nh
      nil
      nix-output-monitor
      alejandra

      ## non-free
      slack
    ]
    ++ (
      if config.hostOption.type == "full"
      then [
        libreoffice-still
      ]
      else []
    );
}
