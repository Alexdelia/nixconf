{
  inputs,
  pkgs,
  ...
}: {
  # swhkd must start with root privileges
  # (it raises to euid 0 at startup to read /dev/input and create the uinput device),
  # the setuid wrapper lets the user systemd service (user/*/home/keyboard/swhkd.nix) start it
  security.wrappers.swhkd = {
    source = "${inputs.swhkd.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/swhkd";
    owner = "root";
    group = "root";
    setuid = true;
  };
}
