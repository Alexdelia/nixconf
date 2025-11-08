_: {
  imports = [
    ./plasma
  ];

  hostOption = {
    work = true;
    type = "lite";

    spec = {
      screen = {
        width = 2880;
        height = 1800;
      };
    };
  };

  stylix = {
    enable = false;

    targets.kde.enable = false;

    cursor.size = 24;
  };
}
