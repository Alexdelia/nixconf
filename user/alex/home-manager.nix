{
  username,
  inputs,
  stateVersion,
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {inherit inputs;};

    users.${username} = (
      (import ./home)
      // (import ./home/mkHome {
        inherit username;
        inherit stateVersion;
        isNixos = true;
      })
    );
  };
}
