{lib, ...}: {
  options.hostOption.spec = lib.mkOption {
    description = "spec/hardware related options";

    type = lib.types.submodule {
      options = {
        wlroots = lib.mkOption {
          description = "Whether the system uses wlroots-based compositor.";
          type = lib.types.bool;
          default = true;
        };

        nvidia = lib.mkOption {
          description = "Whether the system has an NVIDIA GPU.";
          type = lib.types.bool;
          default = false;
        };

        screen = lib.mkOption {
          type = lib.types.submodule {
            options = {
              width = lib.mkOption {
                description = "Screen width in pixels.";
                type = lib.types.int;
                default = 1920;
              };
              height = lib.mkOption {
                description = "Screen height in pixels.";
                type = lib.types.int;
                default = 1080;
              };
            };
          };
        };
      };
    };
  };
}
