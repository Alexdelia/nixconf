{
  description = "Alexdelia's nix/nixos config";

  inputs = let
    stable = "24.05";

    dep = url: {
      inherit url;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  in {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-${stable}";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = dep "github:nix-community/home-manager/release-${stable}";
  };

  outputs = inputs: let
    ilib = import ./lib {inherit inputs;};

    target = {
      # decim = "x86_64-linux";
      work = "aarch64-linux";
      qemu = "x86_64-linux";
    };
  in {
    imports =
      builtins.mapAttrs (
        host: system: (
          import ./host/${host}
          {
            inherit host system;
            inherit inputs;
            inherit ilib;
          }
        )
      )
      target;
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
  };
}
