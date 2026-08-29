{
  config,
  lib,
  pkgs,
  ...
}:
let
  sshHost = "forgejo-ui";
  mapFile = "${config.xdg.stateHome}/nvim/forgejo.json";

  write = pkgs.writeShellApplication {
    name = "nvim-forgejo-map";
    runtimeInputs = with pkgs; [
      openssh
      gnused
      uutils-coreutils-noprefix
    ];
    inheritPath = false;
    text = ''
      cfg="$(ssh -G ${sshHost})"
      host="$(printf '%s\n' "$cfg" | sed -nE 's/^hostname (.+)$/\1/p' | head -1)"
      port="$(printf '%s\n' "$cfg" | sed -nE 's/^localforward ([0-9]+) .*$/\1/p' | head -1)"

      if [ -z "$host" ] || [ -z "$port" ]; then
      	echo "no hostname or local forward found for ${sshHost}" >&2
      	exit 1
      fi

      mkdir -p "$(dirname ${lib.escapeShellArg mapFile})"
      printf '{"%s":{"url":"http://127.0.0.1:%s","flavor":"forgejo"}}\n' "$host" "$port" > ${lib.escapeShellArg mapFile}
    '';
  };
in
{
  systemd.user.services.nvim-forgejo-map = {
    Unit.Description = "forgejo host -> web ui map for nvim OpenRemoteRev (${sshHost})";

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe write;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
