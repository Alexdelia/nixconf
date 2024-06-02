{
  description = "Alexdelia's nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = builtins.mapAttrs (name: system:
      nixpkgs.lib.nixosSystem {
        specialArgs = { hostname = name; };
        modules = [
          ./host/${name}

          # home-manager ...
        ];
      }
    ) {
        # decim="x86_64-linux";
        qemu="x86_64-linux";
    };
  };
}
