{
  config,
  lib,
  pkgs,
  ...
}:
let
  extension = ./no-leave-prompt;
  baseVersion = "1.0";
  id = "hikbpejagmfnfnikhpmjfipkadcnfndm";

  browserDir = "${config.xdg.configHome}/BraveSoftware/Brave-Browser";
  externalDir = "${browserDir}/External Extensions";

  staging = "${config.xdg.cacheHome}/no-leave-prompt";
  crx = "${config.xdg.dataHome}/no-leave-prompt.crx";
  stampFile = "${config.xdg.stateHome}/no-leave-prompt.stamp";

  keyFile = config.sops.secrets."chromium-extension/no-leave-prompt/crx-key".path;

  pack = pkgs.writeShellApplication {
    name = "no-leave-prompt";
    runtimeInputs = [
      pkgs.uutils-coreutils-noprefix
      pkgs.gnused
      pkgs.findutils
      config.programs.chromium.package
    ];
    inheritPath = false;
    text = ''
      # $0 makes a change to this script itself force a repack too
      stamp="${extension} $0"

      if [ "$(cat ${stampFile} 2>/dev/null || true)" = "$stamp" ] &&
      	[ -f ${crx} ] &&
      	[ -f "${externalDir}/${id}.json" ]; then
      	exit 0
      fi

      # chromium only installs an external crx whose version is higher than the
      # installed one, so every repack has to advertise a new build number
      installed="$(
      	find ${browserDir} -maxdepth 5 -type d -path "*/Extensions/${id}/*" -printf '%f\n' 2>/dev/null |
      		sed -nE 's/^${baseVersion}\.([0-9]+)_[0-9]+$/\1/p' |
      		sort -n |
      		tail -1
      )"
      version="${baseVersion}.$(( ''${installed:-0} + 1 ))"

      rm -rf ${staging} ${staging}.crx
      mkdir -p ${staging} "$(dirname ${crx})" "$(dirname ${stampFile})" "${externalDir}"
      cp -r ${extension}/. ${staging}
      chmod -R u+w ${staging}

      sed -i "s|\"version\": *\"[^\"]*\"|\"version\": \"$version\"|" ${staging}/manifest.json

      brave --pack-extension=${staging} --pack-extension-key=${keyFile} --no-sandbox

      mv ${staging}.crx ${crx}
      rm -rf ${staging}

      printf '{"external_crx": "%s", "external_version": "%s"}\n' ${crx} "$version" \
      	> "${externalDir}/${id}.json"

      printf '%s' "$stamp" > ${stampFile}
    '';
  };
in
{
  systemd.user.services.no-leave-prompt = {
    Unit = {
      Description = "extension silencing beforeunload leave site confirmations";
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
