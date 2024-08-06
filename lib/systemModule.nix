{
  hostname,
  inputs,
  stateVersion,
  ...
}: {
  imports = [
    ./extra.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
