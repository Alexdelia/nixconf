{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.hostOption.entertainment.music {
    dp.music = config.terminal.exec { command = "rmpc"; };
  };

  imports = [
    ./mpc.nix
    ./rmpc
    # ./ymuse.nix
  ];
}
