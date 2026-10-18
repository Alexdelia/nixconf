{
  config,
  pkgs,
  lib,
  inputs,
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
    |> map (
      w:
      import w {
        inherit pkgs lib;
        inherit (config) dp;
      }
    )
    |> lib.filter (w: config.wayland.windowManager.sway.enable || w.name == "capture");

  craneLib = inputs.crane.mkLib pkgs;

  common = {
    pname = "iced-widget";
    version = "0.1.0";

    src = craneLib.cleanCargoSource ./.;
    strictDeps = true;

    cargoExtraArgs = spec |> map (w: "--package=${w.name}") |> lib.concatStringsSep " ";
    doCheck = false;

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = runtime;
  };

  workspace = craneLib.buildPackage (
    common
    // {
      cargoArtifacts = craneLib.buildDepsOnly common;

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
    }
  );

  bin =
    name:
    pkgs.runCommand name { } ''
      mkdir -p $out/bin
      cp ${workspace}/bin/${name} $out/bin/
    '';

  nvidiaVulkanOnly = lib.optionalString (
    config.hostOption.spec.nvidia && !config.targets.genericLinux.enable
  ) "WGPU_BACKEND=vulkan VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";

  capture = pkgs.writeShellApplication {
    name = "capture";
    text = ''
      ${nvidiaVulkanOnly} exec ${workspace}/bin/capture "$@"
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
