{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./eza.nix
  ];

  home.packages = with pkgs; [
    # neofetch

    ## nix
    alejandra
  ];
}
