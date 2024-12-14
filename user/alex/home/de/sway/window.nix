{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.hostOption.type == "minimal") {
    wayland.windowManager.sway.config.window = {
      border = 0;
      hideEdgeBorders = "both";
      titlebar = false;
    };
  };
}
