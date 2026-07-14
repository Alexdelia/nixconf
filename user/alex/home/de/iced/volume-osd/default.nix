{
  mkWidget,
  pkgs,
  lib,
}:
mkWidget {
  name = "volume-osd";
  extraEnv = {
    VOLUME_OSD_WPCTL = lib.getExe' pkgs.wireplumber "wpctl";
    VOLUME_OSD_PACTL = lib.getExe' pkgs.pulseaudio "pactl";
  };
}
