{
  inputs,
  hosts,
}:
let
  inherit (inputs.nixpkgs) lib;

  scheme = "${inputs.vity-base24}/vity.yaml";

  mkHomeConfiguration =
    {
      hostname,
      username,
      extraModules ? [ ],
    }:
    let
      hostAttrs = hosts.${hostname};
      userConfigName = if username == "alexandre" then "alex" else username;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit (hostAttrs) system;
        overlays = [ (import ../common/overlay.nix inputs) ];
      };

      extraSpecialArgs = {
        inherit inputs;
      };

      modules = [
        inputs.sops-nix.homeManagerModules.sops

        inputs.base16.homeManagerModule
        { inherit scheme; }

        inputs.stylix.homeModules.stylix
        ../common/stylix.nix

        inputs.plasma-manager.homeModules.plasma-manager

        (import ../common/mkHome.nix {
          inherit username;
          inherit (hostAttrs) stateVersion;
          isNixos = false;
          hostOption = { };
        })
        ../user/${userConfigName}/home
        ../common/standalone-nix.nix

        ./${hostname}
      ]
      ++ extraModules;
    };
in
{
  lib = { inherit mkHomeConfiguration; };

  nixosConfigurations =
    hosts
    |> lib.filterAttrs (_hostname: hostAttrs: hostAttrs.isNixos)
    |> builtins.mapAttrs (
      hostname: hostAttrs:
      lib.nixosSystem {
        inherit (hostAttrs) system;

        modules = [
          inputs.home-manager.nixosModules.home-manager

          inputs.base16.nixosModule
          { inherit scheme; }
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
    );
}
