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

  icedClippy =
    system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      iced = "user/alex/home/de/iced";
    in
    pkgs.writeShellApplication {
      name = "iced-clippy";
      runtimeInputs = with pkgs; [
        cargo
        clippy
        rustc
        pkg-config
        stdenv.cc
      ];
      runtimeEnv.PKG_CONFIG_PATH = pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" (
        import ./${iced}/runtime.nix pkgs
      );
      text = "cargo clippy --manifest-path ${iced}/Cargo.toml --all-targets -- -D warnings";
    };

  checks = forSystems (system: {
    pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
      src = ./.;
      hooks = {
        treefmt = {
          enable = true;
          stages = [ "pre-commit" ];

          packageOverrides.treefmt = treefmtEval.${system}.config.build.wrapper;
        };

        typos = {
          enable = true;
          stages = [ "pre-commit" ];
        };

        shellcheck = {
          enable = true;
          stages = [ "pre-commit" ];
        };

        clippy = {
          enable = true;
          entry = "${icedClippy system}/bin/iced-clippy";
          files = "^user/alex/home/de/iced/.*\\.(rs|toml)$|Cargo\\.lock$";
          pass_filenames = false;
          stages = [ "pre-push" ];
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
