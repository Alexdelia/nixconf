{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.wayland.windowManager.sway.enable {
    wayland.windowManager.sway.config.startup = [
      { command = config.dp.volumeOsd; }
    ];
  };
}
