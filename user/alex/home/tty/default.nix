{pkgs, ...}: {
  dp.term = "${pkgs.alacritty}/bin/alacritty";

  imports = [
    ./alacritty
    # ./kitty
    # ./warp
  ];
}
