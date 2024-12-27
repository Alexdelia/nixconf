{lib, ...}: {
  imports = [
    # ./boot.nix
    ./group.nix
    ./locale.nix
    ./zone.nix
    ./keyboard
    ./sound
    ./service
    ./de
  ];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];

      trusted-users = ["root" "@wheel"];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "copilot.vim"
      "slack"
      "steam"
      "steam-unwrapped"
      "code"
      "vscode"
    ];
}
