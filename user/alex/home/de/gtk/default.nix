{pkgs, ...}: {
  gtk = {
    enable = true;

    theme.name = "Sweet-Dark";
    theme.package = pkgs.sweet;
  };

  stylix.targets.gtk.enable = false;
}
