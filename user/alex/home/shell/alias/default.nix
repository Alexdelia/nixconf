{
  config,
  pkgs,
}:
(import ./short.nix {inherit config pkgs;})
// import ./alternative.nix
// import ./oneliner.nix
// import ./ls.nix
// import ./cd.nix
// import ./git.nix
