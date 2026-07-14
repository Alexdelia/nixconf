{config, ...}: {
  dp.term = config.terminal.command;

  imports = [
    ./alacritty
    # ./kitty
    # ./warp
  ];
}
