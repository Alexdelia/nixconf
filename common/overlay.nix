inputs: final: prev: {
  unstable = import inputs.nixpkgs-unstable {
    inherit (final.stdenv.hostPlatform) system;
    inherit (final) config;
  };

  complete-alias = prev.complete-alias.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./patch/complete-alias-quote-unset-array-subscript.patch
    ];
  });

  material-icons-browser-extension =
    final.callPackage ./package/material-icons-browser-extension.nix
      { };

  swhkd-no-rfkill =
    inputs.swhkd.packages.${final.stdenv.hostPlatform.system}.swhkd-no-rfkill.overrideAttrs
      (old: {
        patches = (old.patches or [ ]) ++ [
          ./patch/swhkd-preserve-supplementary-groups.patch
        ];
      });
}
