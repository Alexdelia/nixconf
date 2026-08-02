inputs: final: _: {
  unstable = import inputs.nixpkgs-unstable {
    inherit (final.stdenv.hostPlatform) system;
    inherit (final) config;
  };

  swhkd-no-rfkill =
    inputs.swhkd.packages.${final.stdenv.hostPlatform.system}.swhkd-no-rfkill.overrideAttrs
      (old: {
        patches = (old.patches or [ ]) ++ [
          ./patch/swhkd-preserve-supplementary-groups.patch
        ];
      });
}
