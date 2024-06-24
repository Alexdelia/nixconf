{
  description = "Alexdelia's nixos config";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = {
    self,
    nixpkgs-unstable,
    nixpkgs-stable,
    home-manager,
    ...
  }: {
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
        # decim="x86_64-linux";
        qemu = "x86_64-linux";
      };
  };
}
