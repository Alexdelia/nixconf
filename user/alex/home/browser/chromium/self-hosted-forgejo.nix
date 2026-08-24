{
  config,
  lib,
  pkgs,
  ...
}:
let
  extension = pkgs.material-icons-browser-extension;
  placeholder = "self-hosted-forgejo.invalid";
  id = "pknjbmepijfoahncaleibaiagmmieecj";

  staging = "${config.xdg.cacheHome}/material-icons-browser-extension";
  crx = "${config.xdg.dataHome}/material-icons-browser-extension.crx";

  portFile = config.sops.secrets."chromium-extension/material-icons/extra-port".path;
  keyFile = config.sops.secrets."chromium-extension/material-icons/crx-key".path;

  pack = pkgs.writeShellApplication {
    name = "material-icons-self-hosted-forgejo";
    runtimeInputs = [
      pkgs.uutils-coreutils-noprefix
      pkgs.gnused
      config.programs.chromium.package
    ];
    text = ''
      port="$(cat ${portFile})"

      rm -rf ${staging} ${staging}.crx
      mkdir -p ${staging} "$(dirname ${crx})"
      cp -r ${extension}/. ${staging}
      chmod -R u+w ${staging}

      sed -i "s|${placeholder}|localhost:$port|g" ${staging}/main.js

      brave --pack-extension=${staging} --pack-extension-key=${keyFile} --no-sandbox

      mv ${staging}.crx ${crx}
      rm -rf ${staging}
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
      ExecStart = lib.getExe pack;
    };

    Install.WantedBy = [ "default.target" ];
  };

  programs.chromium.extensions = [
    {
      inherit id;
      crxPath = crx;
      inherit (extension) version;
    }
  ];
}
