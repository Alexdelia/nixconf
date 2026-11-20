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

  keyheat = "common/package/keyheat";

  keyheatPython =
    system:
    inputs.nixpkgs.legacyPackages.${system}.python3.withPackages (
      python: with python; [
        evdev
        xkbcommon
        jeepney
        pytest
      ]
    );

  keyheatTest =
    system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    pkgs.writeShellApplication {
      name = "keyheat-test";
      runtimeInputs = [
        (keyheatPython system)
        pkgs.nodejs
      ];
      runtimeEnv = {
        KEYHEAT_TEST_XKB_DIR = (import ./${keyheat} { final = pkgs; }).xkb;
        PYTHONDONTWRITEBYTECODE = "1";
      };
      text = "cd ${keyheat} && pytest -q -p no:cacheprovider && node --test tests/model.test.js";
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
          args = [ "--shell=bash" ];
        };

        clippy = {
          enable = true;
          entry = "${icedClippy system}/bin/iced-clippy";
          files = "^user/alex/home/de/iced/.*\\.(rs|toml)$|Cargo\\.lock$";
          pass_filenames = false;
          stages = [ "pre-push" ];
        };

        ruff = {
          enable = true;
          stages = [ "pre-push" ];
        };

        ty = {
          enable = true;
          name = "ty";
          description = "type check every python file";
          entry = "${
            inputs.nixpkgs.lib.getExe inputs.nixpkgs.legacyPackages.${system}.ty
          } check --python ${keyheatPython system}";
          files = "\\.py$";
          stages = [ "pre-push" ];
        };

        keyheat-test = {
          enable = true;
          name = "keyheat pytest";
          entry = "${keyheatTest system}/bin/keyheat-test";
          files = "^${keyheat}/";
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
