{ prev, ... }:
prev.complete-alias.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./quote-unset-array-subscript.patch
  ];
})
