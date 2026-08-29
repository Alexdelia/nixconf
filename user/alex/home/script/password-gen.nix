{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "password-gen";
  runtimeInputs = with pkgs; [ uutils-coreutils-noprefix ];
  text = ''
    tr -dc 'a-zABCDEFGHJKLMNPQRSTUVWXYZ1-9' < /dev/urandom | head -c "''${1:-42}" || true
  '';
}
