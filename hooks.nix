{
  inputs,
  hosts,
}: let
  forSystems =
    inputs.nixpkgs.lib.genAttrs
    (
      inputs.nixpkgs.lib.lists.unique (
        inputs.nixpkgs.lib.mapAttrsToList (_hostname: hostAttrs: hostAttrs.system) hosts
      )
    );

  checks = forSystems (
    system: {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra = {
            enable = true;
            stages = ["pre-commit"];

            settings.verbosity = "quiet";
          };

          deadnix = {
            enable = true;
            stages = ["pre-push"];
          };

          statix = {
            enable = true;
            stages = ["pre-push"];

            settings.format = "stderr";
          };
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
