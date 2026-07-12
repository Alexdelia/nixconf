let
  root = builtins.getFlake (toString ../../../../..);
  pkgs = root.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
  inherit (pkgs) lib;

  runtime = with pkgs; [
    wayland
    vulkan-loader
    libxkbcommon
    libGL
  ];
in
  pkgs.mkShell {
    packages = with pkgs; [
      rustc
      cargo
      clippy
      rustfmt
      rust-analyzer
      pkg-config
    ];

    shellHook =
      /*
      bash
      */
      ''
        export PKG_CONFIG_PATH="${lib.makeSearchPathOutput "dev" "lib/pkgconfig" runtime}''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
        export LD_LIBRARY_PATH="${lib.makeLibraryPath runtime}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      '';
  }
