{
  config,
  ...
}:
let
  color = config.scheme.withHashtag;
in
{
  programs.satty = {
    enable = config.customScript ? imageEdit;

    settings = {
      general = {
        initial-tool = "arrow";
        copy-command = config.dp.clipboard-copy;
        actions-on-enter = [ "save-to-clipboard" ];
        early-exit = true;
      };

      color-palette.palette = [
        "#ff0000"
        color.base09
        color.base0A
        color.base0B
        color.base0C
        color.base0D
        color.base0E
      ];
    };
  };
}
