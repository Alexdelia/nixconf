{
  inputs,
  ilib,
  stateVersion,
}: let
  username = "alex"; # TODO: get from parameters
in {
  imports = [
    (import ./system.nix {
      inherit username;
    })

    ./env.nix

    (import ./home-manager.nix {
      inherit username;
      inherit inputs;
      inherit ilib;
      inherit stateVersion;
    })
  ];
}
