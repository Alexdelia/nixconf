{lib, ...}: {
  options.hostOption.type = lib.mkOption {
    description = "what kind of host is this";

    type = lib.types.enum ["full" "lite" "minimal"];

    default = "lite";
  };
}
