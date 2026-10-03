{ inputs, final, ... }:
(final.unstable.callPackage "${inputs.jerry}/nix/package.nix" {
  imagePreviewSupport = true;
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [
      ./zokoanime-provider.patch
    ];
  })
