{
  lib,
  pkgs,
  config,
  ...
}: let
  clipboard =
    if config.hostOption.spec.wlroots
    then pkgs.wl-clipboard-rs
    else pkgs.wl-clipboard;
in {
  dp = {
    clipboard-copy = "${clipboard}/bin/wl-copy";
    clipboard-paste = "${clipboard}/bin/wl-paste";
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
      bfs
      dysk
      typos
      tlrc
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
    ]
    ++ (
      if config.hostOption.type == "full"
      then [
        libreoffice-still
      ]
      else []
    )
    # ++ (
    #   if config.hostOption.work
    #   then []
    #   else []
    # )
    ++ (
      if (pkgs.system != "aarch64-linux" && !config.targets.genericLinux.enable)
      then [
        slack
      ]
      else []
    );

  nixpkgs.config.allowUnfreePredicate =
    lib.mkIf config.targets.genericLinux.enable
    (
      pkg:
        builtins.elem (lib.getName pkg) [
          "copilot.vim"
          "slack"
          "code"
          "vscode"
        ]
    );
}
