{pkgs, ...}: {
  dp.music = "${pkgs.ymuse}/bin/ymuse";

  imports = [
    ./ymuse.nix
  ];
}
