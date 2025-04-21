{
  config,
  pkgs,
}:
(import ./short.nix {inherit config pkgs;})
// (import ./alternative.nix {inherit pkgs;})
// import ./oneliner.nix
// (import ./ls.nix {inherit pkgs;})
// import ./cd.nix
// import ./git.nix
