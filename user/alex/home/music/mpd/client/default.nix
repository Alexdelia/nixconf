{
  pkgs,
  lib,
  config,
  ...
}: {
  dp.music =
    lib.mkIf config.hostOption.entertainment.music
    "${pkgs.ymuse}/bin/ymuse";

  imports = [
    ./mpc.nix
    ./ymuse.nix
  ];
}
