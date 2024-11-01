{pkgs, ...}: let
  meta = "Mod4";
in {
  wayland.windowManager.sway.config.output.bindsym = {
    "${meta}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
  };
}
