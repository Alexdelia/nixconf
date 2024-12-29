{lib, ...}: {
  options.hostOption.spec = lib.mkOption {
    description = "spec/hardware related options";

    type = lib.types.attrsOf lib.types.anything;

    default = {
      wlroots = true;

      width = 1920;
      height = 1080;
    };
  };
}