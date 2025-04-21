{
  pkgs,
  config,
  ...
}: let
  nom = "${pkgs.nix-output-monitor}/bin/nom";
in {
  s = "sudo";
  pk = "pkill";

  sm = config.dp.systemMonitor;

  y = config.dp.clipboard-copy;
  p = config.dp.clipboard-paste;

  ca = "${pkgs.uutils-coreutils-noprefix}/bin/cat";
  b = "bat";

  v = "nvim";

  c = "cargo";
  mk = "make";

  nd = "${nom} develop";
  nb = "${nom} build";
  nr = "nix run";
  nf = "nix fmt";
}
