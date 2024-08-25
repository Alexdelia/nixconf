{
  imports = [
  	./boot.nix
    ./group.nix
    ./locale.nix
    ./zone.nix
    ./service
    ./de
  ];

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
