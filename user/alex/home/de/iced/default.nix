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

  spec = map (w: import w {inherit pkgs lib;}) [
    ./media-boot-prompt
    ./power-menu
    ./power-tray
    ./volume-osd
  ];

  workspace = pkgs.rustPlatform.buildRustPackage {
    pname = "iced-widget";
    version = "0.1.0";

    src = ./.;
    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "hmerr-0.1.0" = "sha256-sstQowDd0onxnHylO4CjdTOZjHpmrRjh+0bJnHDZaAQ=";
      };
    };

    doCheck = false;

    nativeBuildInputs = with pkgs; [pkg-config];
    buildInputs = runtime;

    env = let
      maple = "Maple Mono NL";
    in
      palette
      // {
        WIDGET_FONT_DEFAULT = maple; # config.stylix.fonts.sansSerif.name;
        WIDGET_FONT_NUMERIC = maple;
        WIDGET_FONT_SYMBOL = "${config.stylix.fonts.sansSerif.name} Propo";
      }
      // lib.mergeAttrsList (map (w: w.env) spec);

    postFixup = ''
      patchelf --add-rpath ${lib.makeLibraryPath runtime} $out/bin/*
    '';
  };

  bin = name:
    pkgs.runCommand name {} ''
      mkdir -p $out/bin
      cp ${workspace}/bin/${name} $out/bin/
    '';

  mediaBootPrompt = bin "media-boot-prompt";
  powerMenuWidget = bin "power-menu";
  powerTray = bin "power-tray";
  volumeOsd = bin "volume-osd";

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
