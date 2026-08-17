{
  lib,
  pkgs,
  ...
}:
let
  ssh = lib.getExe' pkgs.openssh "ssh";
  sshHost = "forgejo-ui";
in
{
  systemd.user.services.forgejo-tunnel = {
    Unit.Description = "ssh tunnel to forgejo web ui (${sshHost})";

    Service = {
      ExecStart = lib.concatStringsSep " " [
        ssh
        "-N"
        "-o BatchMode=yes"
        "-o ExitOnForwardFailure=yes"
        "-o ServerAliveInterval=30"
        "-o ServerAliveCountMax=3"
        sshHost
      ];

      Restart = "always";
      RestartSec = 10;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
