{
  hostname,
  stateVersion,
  users,
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    ../host/${hostname}/hardware-configuration.nix

    ./group.nix
    ./locale.nix
    ./zone.nix
    ./keyboard
    ./sound
    ./service
    ./de
    ./networking.nix
  ]
  ++
    /*
      (
        users |> map (username: (import ../user/${username} {
          inherit username inputs stateVersion;
        }))
      );
    */
    (map (
      username:
      (import ../user/${username} {
        inherit username inputs stateVersion;
      })
    ) users);

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];

      keep-outputs = true;
      keep-derivations = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than ${if config.hostOption.type == "full" then "70d" else "14d"}";
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    let
      name = lib.getName pkg;
    in
    builtins.elem name (
      [
        "copilot.vim"
        "slack"
      ]
      ++ (
        if config.hostOption.entertainment.gaming then
          [
            "steam"
            "steam-unwrapped"
            "osu-lazer-bin"
            # "android-studio"
          ]
        else
          [ ]
      )
    )
    || (config.hostOption.spec.nvidia && lib.hasPrefix "nvidia" name);

  nixpkgs.overlays = [
    (import ../common/overlay.nix inputs)
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
}
