{
  config,
  pkgs,
  ...
}: {
  home.packages = [
    (import ./ns.nix {inherit pkgs;})
    (import ./nr.nix {inherit pkgs;})
    (import ./screenshot.nix {inherit config pkgs;})
    (import ./image-edit.nix {inherit config pkgs;})
  ];
}
