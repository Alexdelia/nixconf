{
  config,
  lib,
  pkgs,
  ...
}:
let
  browserDir = "${config.xdg.configHome}/BraveSoftware/Brave-Browser";
  externalDir = "${browserDir}/External Extensions";

  extensionOptions = {
    options = {
      id = lib.mkOption {
        description = "extension id, derived from keyFile";
        type = lib.types.str;
      };

      src = lib.mkOption {
        description = "unpacked extension";
        type = lib.types.package;
      };

      version = lib.mkOption {
        description = "base version, an installed build number is appended";
        type = lib.types.str;
      };

      keyFile = lib.mkOption {
        description = "private key packing the crx";
        type = lib.types.str;
      };

      stampFiles = lib.mkOption {
        description = "files whose content forces a repack when it changes";
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };

      substitute = lib.mkOption {
        description = "shell run in $staging, with $version set, before packing";
        type = lib.types.lines;
        default = "";
      };
    };
  };

  pack =
    name: extension:
    let
      staging = "${config.xdg.cacheHome}/${name}";
      crx = "${config.xdg.dataHome}/${name}.crx";
      stampFile = "${config.xdg.stateHome}/${name}.stamp";
      json = "${externalDir}/${extension.id}.json";
    in
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.uutils-coreutils-noprefix
        pkgs.gnused
        pkgs.findutils
        pkgs.openssl
        config.programs.chromium.package
      ];
      inheritPath = false;
      text = ''
        # $0 makes a change to this script itself force a repack too
        stamp="${extension.src} $(cat /dev/null ${lib.escapeShellArgs extension.stampFiles} | sha256sum) $0"

        if [ "$(cat ${stampFile} 2>/dev/null || true)" = "$stamp" ] &&
        	[ -f ${crx} ] &&
        	[ -f "${json}" ]; then
        	exit 0
        fi

        id="$(openssl pkey -in ${extension.keyFile} -pubout -outform DER | sha256sum | head -c 32 | tr 0-9a-f a-p)"
        if [ "$id" != ${extension.id} ]; then
        	echo "${extension.keyFile} gives extension id $id, expected ${extension.id}" >&2
        	exit 1
        fi

        # chromium only installs an external crx whose version is higher than the
        # installed one, so every repack has to advertise a new build number
        installed="$(
        	find ${browserDir} -maxdepth 5 -type d -path "*/Extensions/${extension.id}/*" -printf '%f\n' 2>/dev/null |
        		sed -nE 's/^${extension.version}\.([0-9]+)_[0-9]+$/\1/p' |
        		sort -n |
        		tail -1
        )"
        version="${extension.version}.$(( ''${installed:-0} + 1 ))"
        staging=${staging}

        rm -rf "$staging" "$staging.crx"
        mkdir -p "$staging" "$(dirname ${crx})" "$(dirname ${stampFile})" "${externalDir}"
        cp -r ${extension.src}/. "$staging"
        chmod -R u+w "$staging"

        ${extension.substitute}

        sed -i "s|\"version\": *\"[^\"]*\"|\"version\": \"$version\"|" "$staging/manifest.json"

        brave --pack-extension="$staging" --pack-extension-key=${extension.keyFile} --no-sandbox

        mv "$staging.crx" ${crx}
        rm -rf "$staging"

        # a previous generation may have left a symlink into the nix store here
        rm -f "${json}"

        printf '{"external_crx": "%s", "external_version": "%s"}\n' ${crx} "$version" > "${json}"

        printf '%s' "$stamp" > ${stampFile}
      '';
    };
in
{
  options.programs.chromium.localExtensions = lib.mkOption {
    description = "unpacked extensions packed into a crx and installed as external extensions";
    type = lib.types.attrsOf (lib.types.submodule extensionOptions);
    default = { };
  };

  config.systemd.user.services = lib.mapAttrs (name: extension: {
    Unit = {
      Description = "pack and install the ${name} browser extension";
      After = [ "sops-nix.service" ];
      Requires = [ "sops-nix.service" ];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pack name extension);
    };

    Install.WantedBy = [ "default.target" ];
  }) config.programs.chromium.localExtensions;
}
