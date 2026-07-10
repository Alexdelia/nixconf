{
  config,
  pkgs,
  inputs,
  ...
}: let
  swhkd = inputs.swhkd.packages.${pkgs.stdenv.hostPlatform.system}.default;

  swhkdBin =
    if config.targets.genericLinux.enable
    then "/usr/local/bin/swhkd"
    else "/run/wrappers/bin/swhkd";
in {
  home.packages = [swhkd];

  systemd.user.services = {
    swhks = {
      Unit = {
        Description = "swhks environment server for swhkd";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "forking";
        ExecStart = "${swhkd}/bin/swhks";
        Restart = "on-failure";
      };

      Install.WantedBy = ["graphical-session.target"];
    };

    swhkd = {
      Unit = {
        Description = "swhkd hotkey daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target" "swhks.service"];
        Requires = ["swhks.service"];
      };

      Service = {
        ExecStart = swhkdBin;
        Restart = "on-failure";
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
