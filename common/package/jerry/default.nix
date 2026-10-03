{ inputs, final, ... }:
(final.unstable.callPackage "${inputs.jerry}/nix/package.nix" {
  withRofi = true;
  imagePreviewSupport = true;
  infoSupport = true;
}).overrideAttrs
  (old: {
    runtimeInputs = old.runtimeInputs ++ [ final.unstable.libnotify ];
    patches = (old.patches or [ ]) ++ [
      ./zokoanime-provider.patch
      ./anime-menu.patch
    ];
  })
