{checkConfig}: {
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.hostOption.type == "minimal" || config.hostOption.type == "lite") {
    wayland.windowManager.sway.config.input = {
      "1:1:AT_Translated_Set_2_keyboard" = {
        # https://discourse.nixos.org/t/services-xserver-xkb-extralayouts-doesnt-seem-to-be-compatible-with-sway/46128
        xkb_layout =
          if checkConfig
          then "en"
          else "qwerty-dev-ca";
      };
      "1267:12608:ELAN0001:00_04F3:3140_Touchpad" = {
        tap = "enabled";
        natural_scroll = "enabled";
      };
    };
  };
}
