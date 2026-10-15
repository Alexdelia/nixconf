{
  inputs,
  hosts,
}:
let
  forSystems =
    hosts
    |> inputs.nixpkgs.lib.mapAttrsToList (_hostname: hostAttrs: hostAttrs.system)
    |> inputs.nixpkgs.lib.unique
    |> inputs.nixpkgs.lib.genAttrs;

  treefmtEval = forSystems (
    system: inputs.treefmt-nix.lib.evalModule inputs.nixpkgs.legacyPackages.${system} ./treefmt.nix
  );

  checks = forSystems (system: {
    pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
      src = ./.;
      hooks = {
        treefmt = {
          enable = true;
          stages = [ "pre-commit" ];

          packageOverrides.treefmt = treefmtEval.${system}.config.build.wrapper;
        };

        deadnix = {
          enable = true;
          stages = [ "pre-push" ];
        };

        statix = {
          enable = true;
          stages = [ "pre-push" ];

          settings.format = "stderr";
        };
      };
    };
  });
in
{
  inherit checks;

  formatter = forSystems (system: treefmtEval.${system}.config.build.wrapper);

  devShells = forSystems (system: {
    default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
      inherit (checks.${system}.pre-commit-check) shellHook;
      buildInputs = checks.${system}.pre-commit-check.enabledPackages;
    };
  });
}
