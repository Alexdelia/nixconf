{ lib, ... }: {
  options.hostOption.keyheat = lib.mkOption {
    description = "record typing statistics with keyheat";

    type = lib.types.bool;

    default = false;
  };
}
