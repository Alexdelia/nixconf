{
  description = "Alexdelia's nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    /*home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };*/
  };

  outputs = { self, nixpkgs, /*home-manager,*/ ... }@inputs: {
    nixosConfigurations = builtins.mapAttrs (name: system:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          hostname = name;
          /*inherit home-manager;*/
        };
        modules = [ ./host/${name} ];
      }
    ) {
        # decim="x86_64-linux";
        qemu="x86_64-linux";
    };
  };
}
