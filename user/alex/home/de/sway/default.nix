{
  config,
  lib,
  ...
}: {
  imports = [
    ./keybind.nix
    ./window.nix
  ];

  config = lib.mkIf (config.hostOption.type == "minimal") {
    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4";

        terminal = config.dp.term;

        output = {
          "Virtual-1" = {
            mode = "1920x1080@60.000Hz";
          };
        };
      };
    };
  };
}
