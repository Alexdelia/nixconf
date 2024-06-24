{
  config,
  pkgs,
  ...
}: {
  # imports = [];

  home.packages = with pkgs; [
    # neofetch

    ## nix
    alejandra
  ];
}
