{
  lib,
  config,
  scheme ? {},
  ...
}: {
  programs = {
    kitty = {
      enable = true;

      font = lib.mkForce {
        name = "SauceCodePro";
        size = 16;
      };

      keybindings = {
        "kitty_mod+f1" = "discard_event";
      };

      settings =
        {
          enable_audio_bell = false;

          allow_remote_control = true;

          adjust_line_height = 0;
          adjust_column_width = 0;

          adjust_baseline = 0;

          /*
          remember_window_size = false;
          initial_window_width = 900;
          initial_window_height = 900;
          */

          window_border_width = "0.5";
          draw_minimal_borders = true;
          window_margin_width = 0;
          single_window_margin_width = -1;
          window_padding_width = 0;

          placement_strategy = "center";

          hide_window_decorations = false;
          enable_csd = true;
          linux_display_server = "x11";
        }
        // (import ./scheme.nix {
          scheme =
            config.scheme or scheme;
        });
    };
  };

  stylix.targets.kitty.enable = false;
}
