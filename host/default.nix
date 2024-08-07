{
  inputs,
  hosts,
}: {
  nixosConfigurations =
    builtins.mapAttrs (
      hostname: hostAttrs: (
        if !hostAttrs.isNixos
        then null
        else
          inputs.nixpkgs.lib.nixosSystem {
            system = hostAttrs.system;

            modules = [
              inputs.home-manager.nixosModules.home-manager

              ./${hostname}
              {
                _module.args = {
                  inherit inputs;
                  inherit hostname;
                  stateVersion = hostAttrs.stateVersion;
                };
              }
            ];
          }
      )
    )
    hosts;

  homeConfigurations = inputs.nixpkgs.lib.flatten (
    inputs.nixpkgs.lib.mapAttrsToList (
      hostname: hostAttrs:
        if hostAttrs.isNixos
        then []
        else
          inputs.nixpkgs.lib.mapAttrsToList (map (user: {
              name = "${user}@${hostname}";
              value = inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = inputs.nixpkgs.legacyPackages.${hostAttrs.system};

                modules = [
                  (import ../user/${user}/home/mkHome.nix {
                    inherit user;
                    stateVersion = hostAttrs.stateVersion;
                    isNixos = false;
                  })
                  ../user/${user}/home
                ];
              };
            })
            hostAttrs.users)
    )
    hosts
  );
}
