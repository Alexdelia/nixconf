{
  pkgs,
  config,
  ...
}: {
  s = "sudo";
  pk = "pkill";

  sm = config.dp.systemMonitor;

  y = config.dp.clipboard-copy;
  p = config.dp.clipboard-paste;

  b = "bat";

  v = "nvim";

  c = "cargo";
  mk = "make";

  nd = "${pkgs.nix-output-monitor}/bin/nom develop";
}
