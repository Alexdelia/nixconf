_: {
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;

    rustfmt.enable = true;

    stylua = {
      enable = true;
      settings = {
        indent_type = "Tabs";
        indent_width = 4;
      };
    };

    shfmt.enable = true;

    biome.enable = true;

    yamlfmt = {
      enable = true;
      settings.formatter.retain_line_breaks = true;
    };
  };

  settings = {
    global.excludes = [
      ".gitignore"

      "*.lock"

      ".env*"

      "*.toml"

      "*.md"

      # sops-encrypted
      ".sops.yaml"
      "secret/**"

      # no treefmt formatter
      "*.nu"
      "*.yuck"
      "*.xkb"
    ];
  };
}
