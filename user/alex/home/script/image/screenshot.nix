{
  config,
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "screenshot";
  runtimeInputs = with pkgs; [
    grim
    slurp
  ];
  text = ''
    grim -g "$(slurp)" - | ${config.dp.clipboard-copy}
  '';
}
