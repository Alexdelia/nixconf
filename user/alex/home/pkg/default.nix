{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git
    ./eza.nix
  ];

  home.packages = with pkgs; [
    # neofetch

    ## nix
    alejandra
  ];
}
