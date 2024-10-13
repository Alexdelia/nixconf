{config, ...}: {
  imports = [
    ./${config.environment.sessionVariables.XDG_DP_TERMINAL}

    # ./alacritty
    # ./kitty
    # ./warp
  ];
}
