{
  pkgs,
  lib,
  dp,
  ...
}:
{
  name = "capture";
  env = {
    CAPTURE_GRIM = lib.getExe pkgs.grim;
    CAPTURE_WF_RECORDER = lib.getExe pkgs.wf-recorder;
    CAPTURE_SWAYMSG = lib.getExe' pkgs.sway "swaymsg";
    CAPTURE_MAKOCTL = lib.getExe' pkgs.mako "makoctl";
    CAPTURE_MAKO_MODE = (import ../../notification/mode.nix).dnd;
    CAPTURE_NOTIFY_SEND = lib.getExe' pkgs.libnotify "notify-send";
    CAPTURE_CLIPBOARD_COPY = dp.clipboard-copy;
  };
}
