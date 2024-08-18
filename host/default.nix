{
  inputs,
  hosts,
}: let
  scheme = "${inputs.vity-base24}/vity.yaml";
in {
  nixosConfigurations = (
    builtins.mapAttrs (
      hostname: hostAttrs: (
        inputs.nixpkgs.lib.nixosSystem {
          system = hostAttrs.system;

          modules = [
            inputs.home-manager.nixosModules.home-manager

            inputs.base16.nixosModule
            {inherit scheme;}
            inputs.stylix.nixosModules.stylix
            ../common/stylix.nix

            (import ./${hostname}
              {
                inherit inputs;
                inherit hostname;
                users = hostAttrs.users;
                stateVersion = hostAttrs.stateVersion;
              })
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

                extraSpecialArgs = {
                  inherit inputs;
                };

                modules = [
                  inputs.stylix.homeManagerModules.stylix
                  ../common/stylix.nix

                  inputs.base16.homeManagerModule
                  {inherit scheme;}

                  (import ../common/mkHome.nix {
                    inherit username;
                    stateVersion = hostAttrs.stateVersion;
                    isNixos = false;
                  })
                  ../user/${username}/home

                  ./${hostname}
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
