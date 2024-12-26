{pkgs, ...}: let
  coreutils = pkgs.uutils-coreutils-noprefix;

  tr = "${coreutils}/bin/tr";
  head = "${coreutils}/bin/head";
in
  pkgs.writers.writeBashBin
  "password-gen" {}
  /*
  bash
  */
  ''
    ${tr} -dc 'a-zABCDEFGHJKLMNPQRSTUVWXYZ1-9' < /dev/urandom | ${head} -c 42
  ''
