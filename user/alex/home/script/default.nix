{
  pkgs,
  lib,
  ...
}: let
  passwordGen = import ./password-gen.nix {inherit pkgs;};
  killOnPort = import ./kill-on-port.nix {inherit pkgs;};
  baj = import ./baj.nix {inherit pkgs;};
in {
  imports = [
    ./nix
    ./image
    ./docker
  ];

  options.customScript = lib.mkOption {
    description = "custom script I made";

    type = lib.types.attrsOf lib.types.path;

    default = {};
  };

  config = {
    home.packages = [
      passwordGen
      killOnPort
      baj
    ];

    customScript = {
      passwordGen = "${passwordGen}/bin/password-gen";
      killOnPort = "${killOnPort}/bin/kill-on-port";
      baj = "${baj}/bin/baj";
    };
  };
}
