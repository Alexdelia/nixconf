_: {
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true;

    rustfmt.enable = true;

    stylua = {
      enable = true;
      settings = {
        indent_type = "Tabs";
        indent_width = 4;
      };
    };

    shfmt.enable = true;

    prettier = {
      enable = true;
      settings.useTabs = true;
    };
  };

  settings = {
    global.excludes = [
      ".gitignore"

      "*.lock"

      ".env*"

      "*.toml"

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
