{lib, ...}: {
  options.hostOption.spec = lib.mkOption {
    description = "hardware spec of this host";

    type = lib.types.submodule {
      options = {
        wlroots = lib.mkOption {
          description = "uses a wlroots-based compositor";
          type = lib.types.bool;
          default = true;
        };

        nvidia = lib.mkOption {
          description = "has an NVIDIA GPU";
          type = lib.types.bool;
          default = false;
        };

        laptop = lib.mkOption {
          description = "host is a laptop";
          type = lib.types.bool;
          default = false;
        };

        monitor = lib.mkOption {
          description = ''
            monitor of this host, keyed by connector name (e.g. "DP-1", "HDMI-A-1")

            one entry should be `primary = true`
          '';
          default = {};
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              width = lib.mkOption {
                description = "mode width in pixel";
                type = lib.types.int;
              };
              height = lib.mkOption {
                description = "mode height in pixel";
                type = lib.types.int;
              };
              refresh = lib.mkOption {
                description = ''refresh rate in Hz as a string (e.g. "144.003"); null uses the preferred mode'';
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              x = lib.mkOption {
                description = "position x in the output layout";
                type = lib.types.int;
                default = 0;
              };
              y = lib.mkOption {
                description = "position y in the output layout";
                type = lib.types.int;
                default = 0;
              };
              scale = lib.mkOption {
                description = "output scale factor";
                type = lib.types.float;
                default = 1.0;
              };
              adaptiveSync = lib.mkOption {
                description = "enable variable refresh rate (VRR)";
                type = lib.types.bool;
                default = false;
              };
              primary = lib.mkOption {
                description = "primary monitor";
                type = lib.types.bool;
                default = false;
              };
              media = lib.mkOption {
                description = "monitor is used exclusively for media";
                type = lib.types.bool;
                default = false;
              };
            };
          });
        };
      };
    };
  };
}
