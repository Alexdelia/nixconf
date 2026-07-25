{
  config,
  scheme ? {},
  pkgs,
  lib,
  ...
}: let
  c = (config.scheme or scheme).withHashtag;

  mediaEnabled = lib.filterAttrs (_: m: m.media) config.hostOption.spec.monitor != {};

  runtime = with pkgs; [wayland vulkan-loader libxkbcommon libGL];

  palette =
    lib.mapAttrs' (n: v: lib.nameValuePair "WIDGET_${lib.toUpper n}" v)
    (lib.filterAttrs (n: v: builtins.isString v && builtins.match "base[0-9A-Fa-f]{2}" n != null) c);

  mkWidget = {
    name,
    extraBuildInputs ? [],
    extraEnv ? {},
  }:
    pkgs.rustPlatform.buildRustPackage {
      pname = name;
      version = "0.1.0";

      src = ./.;
      cargoLock = {
        lockFile = ./Cargo.lock;
        outputHashes = {
          "hmerr-0.1.0" = "sha256-sstQowDd0onxnHylO4CjdTOZjHpmrRjh+0bJnHDZaAQ=";
        };
      };

      cargoBuildFlags = ["-p" name];
      doCheck = false;

      nativeBuildInputs = with pkgs; [pkg-config];
      buildInputs = runtime ++ extraBuildInputs;

      env = let
        maple = "Maple Mono NL";
      in
        palette
        // {
          WIDGET_FONT_DEFAULT = maple; # config.stylix.fonts.sansSerif.name;
          WIDGET_FONT_NUMERIC = maple;
          WIDGET_FONT_SYMBOL = "${config.stylix.fonts.sansSerif.name} Propo";
        }
        // extraEnv;

      # iced dlopens the wayland/gpu stack at runtime; rpath so it resolves
      postFixup = ''
        patchelf --add-rpath ${lib.makeLibraryPath runtime} $out/bin/${name}
      '';
    };

  mediaBootPrompt = import ./media-boot-prompt {inherit mkWidget;};
  powerMenuWidget = import ./power-menu {inherit mkWidget;};
  powerTray = import ./power-tray {inherit mkWidget;};
  volumeOsd = import ./volume-osd {inherit mkWidget pkgs lib;};

  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = with pkgs; [systemd];
    text = ''
      choice="$(${powerMenuWidget}/bin/power-menu)" || exit 0
      read -ra cmd <<<"$choice"
      exec "''${cmd[@]}"
    '';
  };
in {
  config = lib.mkIf config.wayland.windowManager.sway.enable (lib.mkMerge [
    {
      dp.volumeOsd = "${volumeOsd}/bin/volume-osd";
      dp.powerMenu = "${powerMenu}/bin/power-menu";
    }
    (lib.mkIf mediaEnabled {
      dp.mediaBootPrompt = "${mediaBootPrompt}/bin/media-boot-prompt";
      dp.powerTray = "${powerTray}/bin/power-tray";
    })
  ]);
}
