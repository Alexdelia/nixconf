{
  description = "Alexdelia's nix/nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";
    vity-base24 = {
      url = "github:Alexdelia/vity-base24";
      flake = false;
    };
  };

  outputs = inputs: let
    hosts = {
      /*
      decim = {
        system = "x86_64-linux";
        stateVersion = "24.05";
        isNixos = true;
        users = ["alex"];
      };
      */
      melons = {
        system = "x86_64-linux";
        stateVersion = "24.05";
        isNixos = true;
        users = ["alex"];
      };
      work = {
        system = "aarch64-linux";
        stateVersion = "24.05";
        isNixos = false;
        users = ["alex"];
      };
      /*
      qemu = {
        system = "x86_64-linux";
        stateVersion = "23.11";
        isNixos = true;
        users = ["alex"];
      };
      */
    };
  in (import ./host {
    inherit inputs;
    inherit hosts;
  });
}
