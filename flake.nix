{
  description = "Alexdelia's nix/nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    hosts = {
      # decim = "x86_64-linux";
      work = "aarch64-linux";
      melons = "x86_64-linux";
      qemu = "x86_64-linux";
    };
  in (import ./host {
    inherit inputs;
    hosts = {
      melons = {
        system = "x86_64-linux";
        stateVersion = "24.05";
        isNixos = true;
        users = ["alex"];
      };
    };
  });
  /*
  nixosConfigurations = (
    builtins.mapAttrs (
      host: system:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            inputs.nixosModules.home-manager

            ./host/${host}
            {
              _module.args = {
                hostname = host;
                inherit inputs;
              };
            }
          ];
        }
    )
    hosts
  );

  homeConfigurations = (
    builtins.map (
      username: ilib.mkStandaloneHome {inherit username system stateVersion;}
    )
    users
  );
  */

  /*
  nixosConfigurations =
    builtins.mapAttrs (
      name: system:
        nixpkgs-stable.lib.nixosSystem {
          inherit system;

          modules = [
            home-manager.nixosModules.home-manager

            ./host/${name}
            {
              _module.args = {
                hostname = name;
                inherit nixpkgs-unstable;
                inherit home-manager;
              };
            }
          ];
        }
    ) {
      # decim = "x86_64-linux";
      qemu = "x86_64-linux";
      work = "aarch64-linux";
    };
  */
}
