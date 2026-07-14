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
      cargoLock.lockFile = ./Cargo.lock;

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
          WIDGET_FONT_SYMBOL = config.stylix.fonts.sansSerif.name;
        }
        // extraEnv;

      # iced dlopens the wayland/gpu stack at runtime; rpath so it resolves
      postFixup = ''
        patchelf --add-rpath ${lib.makeLibraryPath runtime} $out/bin/${name}
      '';
    };

  mediaBootPrompt = import ./media-boot-prompt {inherit mkWidget;};
  volumeOsd = import ./volume-osd {inherit mkWidget pkgs lib;};
in {
  config = lib.mkIf config.wayland.windowManager.sway.enable (lib.mkMerge [
    {dp.volumeOsd = "${volumeOsd}/bin/volume-osd";}
    (lib.mkIf mediaEnabled {
      dp.mediaBootPrompt = "${mediaBootPrompt}/bin/media-boot-prompt";
    })
  ]);
}
