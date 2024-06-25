{
  imports = [
    ./locale.nix
    ./de
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  nixpkgs.config.allowUnfree = true;
}
