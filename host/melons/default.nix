{
  inputs,
  hostname,
  ...
}: let
  system = "x86_64-linux";

  stateVersion = "24.05";

  users = [
    "alex"
  ];
in (import ../../lib/mkNixosConfigurations.nix {
  inherit inputs;
  inherit hostname system;
  inherit users;
  inherit stateVersion;
})
