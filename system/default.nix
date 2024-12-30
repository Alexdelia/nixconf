{
  hostname,
  stateVersion,
  users,
  inputs,
  lib,
  ...
}: {
  imports =
    [
      ../host/${hostname}/hardware-configuration.nix

      # ./boot.nix
      ./group.nix
      ./locale.nix
      ./zone.nix
      ./keyboard
      ./sound
      ./service
      ./de
    ]
    ++ (
      users |> map (username: (import ../user/${username} {
        inherit username inputs stateVersion;
      }))
    );

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes" "pipe-operators"];

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

  # TODO: remove duplicate
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
}
