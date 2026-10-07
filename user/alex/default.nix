{
  inputs,
  stateVersion,
  username,
}:
{
  imports = [
    (import ./system.nix {
      inherit username;
    })

    ./env.nix

    (import ./vault {
      inherit username;
    })

    (import ./home-manager.nix {
      inherit username;
      inherit inputs;
      inherit stateVersion;
    })
  ];
}
