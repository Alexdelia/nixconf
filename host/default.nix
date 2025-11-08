{
  inputs,
  hosts,
}: let
  scheme = "${inputs.vity-base24}/vity.yaml";
in {
  nixosConfigurations =
    builtins.mapAttrs (
      hostname: hostAttrs: (
        inputs.nixpkgs.lib.nixosSystem {
          inherit (hostAttrs) system;

          modules = [
            inputs.home-manager.nixosModules.home-manager

            inputs.base16.nixosModule
            {inherit scheme;}
            inputs.stylix.nixosModules.stylix
            ../common/stylix.nix

            ../common/option/host-option/default.nix
            ../common/option/host-option/nixos-module.nix
            ./${hostname}
          ];

          specialArgs = {
            inherit inputs;
            inherit hostname;
            inherit (hostAttrs) users;
            inherit (hostAttrs) stateVersion;
          };
        }
      )
    )
    (inputs.nixpkgs.lib.filterAttrs (_hostname: hostAttrs: hostAttrs.isNixos) hosts);

  homeConfigurations = builtins.listToAttrs (
    builtins.concatLists (map (
        hostname: let
          hostAttrs = hosts.${hostname};
        in
          map (username: (let
            userConfigName =
              if username == "alexandre"
              then "alex"
              else username;
          in {
            name = "${username}@${hostname}";
            value = inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = inputs.nixpkgs.legacyPackages.${hostAttrs.system};

              extraSpecialArgs = {
                inherit inputs;
              };

              modules = [
                inputs.sops-nix.homeManagerModules.sops

                inputs.base16.homeManagerModule
                {inherit scheme;}

                inputs.stylix.homeModules.stylix
                ../common/stylix.nix

                inputs.plasma-manager.homeModules.plasma-manager

                (import ../common/mkHome.nix {
                  inherit username;
                  inherit (hostAttrs) stateVersion;
                  isNixos = false;
                  hostOption = {};
                })
                ../user/${userConfigName}/home

                ./${hostname}
              ];
            };
          }))
          hostAttrs.users
      ) (
        builtins.attrNames
        (inputs.nixpkgs.lib.filterAttrs (_hostname: hostAttrs: !hostAttrs.isNixos) hosts)
      ))
  );
}
