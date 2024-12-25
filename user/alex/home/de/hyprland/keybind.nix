{
  config,
  pkgs,
  ...
}: {
  home.packages =
    if (config.hostOption.type == "lite")
    then
      with pkgs; [
        brightnessctl
      ]
    else [];

  wayland.windowManager.hyprland.settings = {
    bind = [
      "$mod, C, exec, ${config.dp.term}"
      "$mod, B, exec, ${config.dp.browser}"
      "$mod, K, exec, ${config.dp.calculator}"

      # "$mod, A, exec, ${config.dp.infoHub}"
      # "$mod, W, exec, ${config.dp.powermenu}"

      "$mod, S, exec, screenshot"
      "$mod, I, exec, image-edit"
      "$mod, Q, exec, ${config.dp.colorpicker}"

      "$mod SHIFT, Q, killactive,"
      "$mod SHIFT, M, exit,"

      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"

      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"
    ];

    # e -> repeat, will repeat when held.
    # l -> locked, will also work when an input inhibitor (e.g. a lockscreen) is active.
    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"

      ",XF86MonBrightnessDown, exec, brightnessctl set 2%-"
      ",XF86MonBrightnessUp, exec, brightnessctl set 2%+"
    ];

    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ];
  };
}
