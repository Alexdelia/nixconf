{
  inputs,
  pkgs,
  ...
}: {
  security.wrappers.swhkd = {
    source = "${inputs.swhkd.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/swhkd";
    owner = "root";
    group = "root";
    setuid = true;
  };
}
