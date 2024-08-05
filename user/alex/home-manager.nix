{
  username,
  inputs,
  ilib,
  stateVersion,
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {inherit inputs;};

    users.${username} = (
      (import ./home)
      // (ilib.mkHome {
        inherit username;
        inherit inputs;
      })
    );
  };
}
