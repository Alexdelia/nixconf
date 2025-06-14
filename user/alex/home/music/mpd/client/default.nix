{
  lib,
  config,
  ...
}: {
  dp.music =
    lib.mkIf config.hostOption.entertainment.music
    "alacritty -e rmpc";

  imports = [
    ./mpc.nix
    ./rmpc.nix
    # ./ymuse.nix
  ];
}
