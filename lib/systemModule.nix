{
  hostname,
  inputs,
  stateVersion,
  ...
}: {
  imports = [
    (import ../host/${hostname}/extra.nix {inherit inputs;})
    ../host/${hostname}/hardware-configuration.nix
    ../system
    # TODO: iterate over users to import and `inherit username;`
    (import ../user/alex {
      inherit inputs;
      ilib = {
        mkHome = import ./mkHome.nix;
      };
      inherit stateVersion;
    })
  ];

  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
