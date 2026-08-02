{ pkgs, ... }: {
  gtk = {
    enable = true;

    # theme = {
    #   name = "Sweet-Dark";
    #   package = pkgs.sweet;
    # };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk2.force = true;
  };

  # stylix.targets.gtk.enable = false;
}
