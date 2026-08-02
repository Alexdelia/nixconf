{
  lib,
  config,
  ...
}:
{
  dp.music = lib.mkIf config.hostOption.entertainment.music (
    config.terminal.exec { command = "rmpc"; }
  );

  imports = [
    ./mpc.nix
    ./rmpc
    # ./ymuse.nix
  ];
}
