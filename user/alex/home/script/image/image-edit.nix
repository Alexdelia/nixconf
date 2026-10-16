{
  config,
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "image-edit";
  runtimeInputs = with pkgs; [ satty ];
  text = ''
    ${config.dp.clipboard-paste} | satty -f -
  '';
}
