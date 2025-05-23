{
  description = "Alexdelia's nix/nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16.url = "github:SenchoPens/base16.nix";
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vity-base24 = {
      url = "github:Alexdelia/vity-base24";
      flake = false;
    };
    vity-nvim.url = "github:Alexdelia/vity.nvim";

    eww = {
      url = "github:elkowar/eww";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    hosts = {
      jiruo = {
        system = "x86_64-linux";
        stateVersion = "24.05";
        isNixos = true;
        users = ["alex"];
      };
      marulk = {
        system = "x86_64-linux";
        stateVersion = "24.05";
        isNixos = true;
        users = ["alex"];
      };
      riko = {
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
    };
  in
    (import ./host {
      inherit inputs;
      inherit hosts;
    })
    // (import ./hooks.nix {
      inherit inputs;
      inherit hosts;
    });
}
