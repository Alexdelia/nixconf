{
  config,
  scheme ? {},
  ...
}: {
  programs = {
    alacritty = {
      enable = true;

      settings =
        {
          env = {
            TERM = "xterm-256color";
          };

          live_config_reload = false;

          font = {
            size = 16.0;

            normal = {
              family = "SourceCodePro";
              style = "Regular";
            };
            bold = {
              family = "SourceCodePro";
              style = "Black";
            };
          };

          window = {
            opacity = 1.0;

            decorations = "None";
            startup_mode = "Maximized";

            dimensions = {
              columns = 128;
              lines = 32;
            };
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
