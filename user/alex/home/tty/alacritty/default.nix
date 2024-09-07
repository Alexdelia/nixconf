{
  lib,
  config,
  scheme ? {},
  ...
}: {
  programs = {
    alacritty = {
      enable = true;

      settings =
        {
          live_config_reload = false;

          font = {
            size = 16.0;

            normal = {
              family = "SourceCodePro Nerd Font";
              style = "Regular";
            };
          };

          window = {
            opacity = 1.0;

            decorations = "None";
            startup_mode = "Maximized";
          };
        }
        // (import ./scheme.nix {
          scheme =
            if config ? scheme
            then config.scheme
            else scheme;
        });
    };
  };

  stylix.targets.alacritty.enable = false;
}
