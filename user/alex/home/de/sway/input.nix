{checkConfig}: {
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.hostOption.type == "minimal" || config.hostOption.type == "lite") {
    wayland.windowManager.sway.config.input =
      {
        "type:pointer" = {
          accel_profile = "flat";
          pointer_accel = "0.7";
        };

        "type:keyboard" = {
          xkb_layout =
            if !checkConfig
            then "qwerty-dev-ca"
            else "us";
        };
      }
      // lib.optionalAttrs config.hostOption.spec.laptop {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };
  };
}
