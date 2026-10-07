{ lib, ... }: {
  options.hostOption.vault = lib.mkOption {
    description = "encrypted git repo with multi storage sync";

    type = lib.types.nullOr (
      lib.types.submodule {
        options = {
          usb = lib.mkOption {
            description = "usb UUID mirror";
            type = lib.types.str;
          };

          hdd = lib.mkOption {
            description = "hdd path mirror";
            type = lib.types.externalPath;
          };
        };
      }
    );

    default = null;
  };
}
