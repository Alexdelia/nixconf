{ config, ... }: {
  dp.term = config.terminal.command;

  imports = [
    ./alacritty
    ./foot
    # ./kitty
    # ./warp
  ];
}
