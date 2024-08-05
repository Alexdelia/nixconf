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
        (import ../../user/alex {
          inherit inputs;
          ilib = {
            mkHome = import ./mkHome.nix {
              username = "alex"; # TODO: get from iteration
              inherit stateVersion;
              isNixos = true;
            };
          };
          inherit stateVersion;
        }) # TODO: iterate over users to import and `inherit username;`
      ];

      networking.hostName = hostname;
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
