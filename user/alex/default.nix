{ lib, /*home-manager,*/ ... }:
let
  username = "alex";
in {
  imports = [
    #./system.nix
    ( import ./system.nix {
      inherit username;
    })
    /*( import ./home {
      inherit username;
      inherit home-manager;
    })*/
  ];
}
