inputs: final: prev:
{
  unstable = import inputs.nixpkgs-unstable {
    inherit (final.stdenv.hostPlatform) system;
    inherit (final) config;
  };
}
// (
  builtins.readDir ./package
  |> prev.lib.filterAttrs (_: type: type == "directory")
  |> builtins.mapAttrs (name: _: import ./package/${name} { inherit inputs final prev; })
)
