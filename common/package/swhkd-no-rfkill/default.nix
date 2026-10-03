{ inputs, final, ... }:
inputs.swhkd.packages.${final.stdenv.hostPlatform.system}.swhkd-no-rfkill.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./preserve-supplementary-groups.patch
  ];
})
