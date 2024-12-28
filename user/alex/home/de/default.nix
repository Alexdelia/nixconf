{
  # config,
  # scheme ? {},
  # pkgs,
  ...
}: {
  imports = [
    # ./hyprland
    ./sway

    # ./eww

    ./gtk
    # ./qt
  ];

  /*
  home.packages = with pkgs; [
    maple-mono
  ];

  home.file."${config.xdg.configHome}/rice/color.scss".text = let
    c = (config.scheme or scheme).withHashtag;
  in ''
    $base00:${c.base00};
    $base01:${c.base01};
    $base02:${c.base02};
    $base03:${c.base03};
    $base04:${c.base04};
    $base05:${c.base05};
    $base06:${c.base06};
    $base07:${c.base07};
    $base08:${c.base08};
    $base09:${c.base09};
    $base0A:${c.base0A};
    $base0B:${c.base0B};
    $base0C:${c.base0C};
    $base0D:${c.base0D};
    $base0E:${c.base0E};
    $base0F:${c.base0F};
  '';
  */
}
