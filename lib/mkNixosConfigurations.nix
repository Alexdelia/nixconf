{inputs}: (
  {
    hostname,
    system,
    users,
    stateVersion,
  }: let
    systemModule = {...}: {
      imports = [
        (import ../host/${hostname}/extra.nix {inherit inputs;})
        ../host/${hostname}/hardware-configuration.nix
        ../system
        (import ../../user/alex {inherit inputs;})
      ];
    };
  in {
    nixosConfigurations = {
      ${hostname} = inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          inputs.nixosModules.home-manager

          ../host/${hostname}
          {
            _module.args = {
              inherit hostname;
              inherit inputs;
            };
          }
        ];
      };
    };
  }
)
