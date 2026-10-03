{ inputs, final, ... }:
(final.unstable.callPackage "${inputs.jerry}/nix/package.nix" { }).overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./zokoanime-provider.patch
  ];
})
