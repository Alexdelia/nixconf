{
  inputs,
  hosts,
}: {
  nixosConfigurations =
    builtins.mapAttrs (
      hostname: hostAttrs:
        nixpkgs-stable.lib.nixosSystem {
          system = hostAttrs.system;

          modules = [
            inputs.home-manager.nixosModules.home-manager

            ./host/${hostname}
            {
              _module.args = {
                inherit hostname hostAttrs;
                inherit inputs;
              };
            }
          ];
        }
    )
    hosts;
}
