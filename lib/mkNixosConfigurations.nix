{
  inputs,
  hostname,
}: {
  nixosConfigurations = {
    ${hostname} = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        inputs.home-manager.nixosModules.home-manager

        ./systemModule.nix
        {
          _module.args = {
            inherit hostname;
            inherit inputs;
            inherit stateVersion;
          };
        }
      ];
    };
  };
}
