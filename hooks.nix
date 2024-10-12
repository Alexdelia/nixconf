{
  inputs,
  hosts,
}: let
  forSystems =
    inputs.nixpkgs.lib.genAttrs
    (
      inputs.nixpkgs.lib.lists.unique (
        inputs.nixpkgs.lib.mapAttrsToList (name: host: host.system) hosts
      )
    );

  checks = forSystems (
    system: {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
        };
      };
    }
  );
in {
  inherit checks;

  devShells = forSystems (
    system: {
      default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
        inherit (checks.${system}.pre-commit-check) shellHook;
        buildInputs = checks.${system}.pre-commit-check.enabledPackages;
      };
    }
  );
}
