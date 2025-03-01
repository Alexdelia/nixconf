{pkgs, ...}: {
  dp.systemMonitor = "${pkgs.btop}/bin/btop";

  imports = [
    # ./bottom.nix
    ./btop.nix
  ];
}
