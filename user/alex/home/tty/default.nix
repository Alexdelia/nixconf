{ config, ... }: {
  dp.term = config.terminal.command;

  imports = [
    ./foot
    # ./alacritty
    # ./kitty
    # ./warp
  ];
}
