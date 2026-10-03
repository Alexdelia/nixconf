{ inputs, final, ... }:
(final.unstable.callPackage "${inputs.jerry}/nix/package.nix" {
  imagePreviewSupport = true;
  infoSupport = true;
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [
      ./zokoanime-provider.patch
      ./anime-list-menu.patch
    ];
  })
