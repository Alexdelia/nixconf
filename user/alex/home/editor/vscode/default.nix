{
  pkgs,
  config,
  ...
}: {
  programs.vscode = {
    enable = !config.targets.genericLinux.enable;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [rustup zlib openssl.dev pkg-config]);
  };

  stylix.targets.vscode.enable = false;
}
