{
  config,
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "image-edit";
  runtimeInputs = with pkgs; [ swappy ];
  text = ''
    ${config.dp.clipboard-paste} | swappy -f -
  '';
}
