{
  pkgs,
  lib,
  ...
}: {
  name = "volume-osd";
  env = {
    VOLUME_OSD_WPCTL = lib.getExe' pkgs.wireplumber "wpctl";
    VOLUME_OSD_PACTL = lib.getExe' pkgs.pulseaudio "pactl";
  };
}
