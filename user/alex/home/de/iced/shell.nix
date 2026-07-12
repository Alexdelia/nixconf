let
  root = builtins.getFlake (toString ../../../../..);
  pkgs = root.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};

  runtime = with pkgs; [
    wayland
    vulkan-loader
    libxkbcommon
    libGL
  ];
in
  pkgs.mkShell {
    nativeBuildInputs = with pkgs; [pkg-config];

    buildInputs =
      (with pkgs; [
        rustc
        cargo
        clippy
        rustfmt
        rust-analyzer
      ])
      ++ runtime;

    # iced dlopens the wayland/gpu stack at runtime; dev builds have no rpath
    shellHook =
      /*
      bash
      */
      ''
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtime}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      '';
  }
