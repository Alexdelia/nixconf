_: {
  imports = [
    ./plasma
    ./forgejo-tunnel.nix
    ./forgejo-web-map.nix
  ];

  hostOption = {
    work = true;
    type = "lite";

    spec = {
      monitor = {
        # TODO: set correct monitor name
        "eDP-1" = {
          width = 2880;
          height = 1800;
          primary = true;
        };
      };
    };
  };

  stylix = {
    enable = false;

    targets.kde.enable = false;

    cursor.size = 24;
  };
}
