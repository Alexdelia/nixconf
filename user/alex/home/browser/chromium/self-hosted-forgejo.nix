{
  config,
  lib,
  pkgs,
  ...
}:
let
  extension = pkgs.material-icons-browser-extension;
  placeholder = "self-hosted-forgejo.invalid";

  directory = "${config.xdg.dataHome}/material-icons-browser-extension";
  portFile = config.sops.secrets."forgejo-ui/port".path;

  materialize = pkgs.writeShellApplication {
    name = "material-icons-self-hosted-forgejo";
    runtimeInputs = with pkgs; [
      uutils-coreutils-noprefix
      gnused
    ];
    text = ''
      port="$(cat ${portFile})"

      rm -rf ${directory}
      mkdir -p ${directory}
      cp -r ${extension}/. ${directory}
      chmod -R u+w ${directory}

      sed -i "s|${placeholder}|localhost:$port|g" ${directory}/main.js
    '';
  };
in
{
  systemd.user.services.material-icons-self-hosted-forgejo = {
    Unit = {
      Description = "material icons extension pointed at localhost forgejo";
      After = [ "sops-nix.service" ];
      Requires = [ "sops-nix.service" ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe materialize;
    };

    Install.WantedBy = [ "default.target" ];
  };

  programs.chromium.commandLineArgs = [ "--load-extension=${directory}" ];
}
