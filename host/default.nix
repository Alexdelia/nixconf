{
  inputs,
  hosts,
}: {
  nixosConfigurations = (
    builtins.mapAttrs (
      hostname: hostAttrs: (
        inputs.nixpkgs.lib.nixosSystem {
          system = hostAttrs.system;

          modules = [
            inputs.home-manager.nixosModules.home-manager
            inputs.stylix.nixosModules.stylix

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
    (inputs.nixpkgs.lib.filterAttrs (hostname: hostAttrs: hostAttrs.isNixos) hosts)
  );

  homeConfigurations = (
    builtins.listToAttrs (
      builtins.concatLists (map (
          hostname: let
            hostAttrs = hosts.${hostname};
          in
            map (username: {
              name = "${username}@${hostname}";
              value = inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = inputs.nixpkgs.legacyPackages.${hostAttrs.system};

                modules = [
                  inputs.stylix.homeManagerModules.stylix

                  (import ../common/mkHome.nix {
                    inherit username;
                    stateVersion = hostAttrs.stateVersion;
                    isNixos = false;
                  })
                  ../user/${username}/home
                ];
              };
            })
            hostAttrs.users
        ) (
          builtins.attrNames
          (inputs.nixpkgs.lib.filterAttrs (hostname: hostAttrs: !hostAttrs.isNixos) hosts)
        ))
    )
  );
}
