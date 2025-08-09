{
  pkgs,
  lib,
  ...
}: let
  passwordGen = import ./password-gen.nix {inherit pkgs;};
in {
  imports = [
    ./nix
    ./image
    ./docker
    ./ani-cli
  ];

  options.customScript = lib.mkOption {
    description = "custom script I made";

    type = lib.types.attrsOf lib.types.path;

    default = {};
  };

  config = {
    home.packages = [
      passwordGen
    ];

    customScript = {
      passwordGen = "${passwordGen}/bin/password-gen";
    };
  };
}
