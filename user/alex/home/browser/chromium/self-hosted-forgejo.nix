{
  config,
  lib,
  pkgs,
  ...
}:
let
  extension = pkgs.material-icons-browser-extension;
  placeholder = {
    host = "self-hosted-forgejo.invalid";
    ip = "self-hosted-forgejo-ip.invalid";
  };
  id = "pknjbmepijfoahncaleibaiagmmieecj";

  browserDir = "${config.xdg.configHome}/BraveSoftware/Brave-Browser";
  externalDir = "${browserDir}/External Extensions";

  staging = "${config.xdg.cacheHome}/material-icons-browser-extension";
  crx = "${config.xdg.dataHome}/material-icons-browser-extension.crx";
  stampFile = "${config.xdg.stateHome}/material-icons-browser-extension.stamp";

  portFile = config.sops.secrets."chromium-extension/material-icons/extra-port".path;
  keyFile = config.sops.secrets."chromium-extension/material-icons/crx-key".path;

  pack = pkgs.writeShellApplication {
    name = "material-icons-self-hosted-forgejo";
    runtimeInputs = [
      pkgs.uutils-coreutils-noprefix
      pkgs.gnused
      pkgs.findutils
      config.programs.chromium.package
    ];
    inheritPath = false;
    text = ''
      port="$(cat ${portFile})"
      # $0 makes a change to this script itself force a repack too
      stamp="${extension} $port $0"

      if [ "$(cat ${stampFile} 2>/dev/null || true)" = "$stamp" ] &&
      	[ -f ${crx} ] &&
      	[ -f "${externalDir}/${id}.json" ]; then
      	exit 0
      fi

      # chromium only installs an external crx whose version is higher than the
      # installed one, so every repack has to advertise a new build number
      installed="$(
      	find ${browserDir} -maxdepth 5 -type d -path "*/Extensions/${id}/*" -printf '%f\n' 2>/dev/null |
      		sed -nE 's/^${extension.version}\.([0-9]+)_[0-9]+$/\1/p' |
      		sort -n |
      		tail -1
      )"
      version="${extension.version}.$(( ''${installed:-0} + 1 ))"

      rm -rf ${staging} ${staging}.crx
      mkdir -p ${staging} "$(dirname ${crx})" "$(dirname ${stampFile})" "${externalDir}"
      cp -r ${extension}/. ${staging}
      chmod -R u+w ${staging}

      sed -i "s|${placeholder.host}|localhost:$port|g" ${staging}/main.js
      sed -i "s|${placeholder.ip}|127.0.0.1:$port|g" ${staging}/main.js
      sed -i "s|\"version\": *\"[^\"]*\"|\"version\": \"$version\"|" ${staging}/manifest.json

      brave --pack-extension=${staging} --pack-extension-key=${keyFile} --no-sandbox

      mv ${staging}.crx ${crx}
      rm -rf ${staging}

      # a previous generation may have left a symlink into the nix store here
      rm -f "${externalDir}/${id}.json"

      printf '{"external_crx": "%s", "external_version": "%s"}\n' ${crx} "$version" \
      	> "${externalDir}/${id}.json"

      printf '%s' "$stamp" > ${stampFile}
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
}
