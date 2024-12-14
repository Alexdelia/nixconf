{pkgs, ...}: {
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
  };

  # stylix.targets.gtk.enable = false;
}
