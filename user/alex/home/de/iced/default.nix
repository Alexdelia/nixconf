{
  config,
  pkgs,
  lib,
  ...
}:
let
  c = config.scheme.withHashtag;

  mediaEnabled = config.hostOption.spec.monitor |> lib.attrValues |> lib.any (m: m.media);

  runtime = with pkgs; [
    wayland
    vulkan-loader
    libxkbcommon
    libGL
  ];

  palette =
    c
    |> lib.filterAttrs (n: v: builtins.isString v && builtins.match "base[0-9A-Fa-f]{2}" n != null)
    |> lib.mapAttrs' (n: v: lib.nameValuePair "WIDGET_${lib.toUpper n}" v);

  spec =
    [
      ./capture
      ./media-boot-prompt
      ./power-menu
      ./power-tray
      ./volume-osd
    ]
    |> map (w: import w { inherit pkgs lib; })
    |> lib.filter (w: config.wayland.windowManager.sway.enable || w.name == "capture");

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

    cargoBuildFlags = spec |> map (w: "--package=${w.name}");
    doCheck = false;

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = runtime;

    env =
      let
        maple = "Maple Mono NL";
      in
      palette
      // {
        WIDGET_FONT_DEFAULT = maple; # config.stylix.fonts.sansSerif.name;
        WIDGET_FONT_NUMERIC = maple;
        WIDGET_FONT_SYMBOL = "${config.stylix.fonts.sansSerif.name} Propo";
      }
      // (spec |> map (w: w.env) |> lib.mergeAttrsList);

    postFixup = ''
      patchelf --add-rpath ${lib.makeLibraryPath runtime} $out/bin/*
    '';
  };

  bin =
    name:
    pkgs.runCommand name { } ''
      mkdir -p $out/bin
      cp ${workspace}/bin/${name} $out/bin/
    '';

  capture = pkgs.writeShellApplication {
    name = "capture";
    text = ''
      CAPTURE_CLIPBOARD_COPY=${config.dp.clipboard-copy} exec ${workspace}/bin/capture "$@"
    '';
  };
  mediaBootPrompt = bin "media-boot-prompt";
  powerMenuWidget = bin "power-menu";
  powerTray = bin "power-tray";
  volumeOsd = bin "volume-osd";

  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = with pkgs; [ systemd ];
    text = ''
      choice="$(${powerMenuWidget}/bin/power-menu)" || exit 0
      read -ra cmd <<<"$choice"
      exec "''${cmd[@]}"
    '';
  };
in
{
  config = lib.mkMerge [
    {
      home.packages = [ capture ];
      customScript.capture = "${capture}/bin/capture";
    }
    (lib.mkIf config.wayland.windowManager.sway.enable (
      lib.mkMerge [
        {
          dp.volumeOsd = "${volumeOsd}/bin/volume-osd";
          dp.powerMenu = "${powerMenu}/bin/power-menu";
        }
        (lib.mkIf mediaEnabled {
          dp.mediaBootPrompt = "${mediaBootPrompt}/bin/media-boot-prompt";
          dp.powerTray = "${powerTray}/bin/power-tray";
        })
      ]
    ))
  ];
}
