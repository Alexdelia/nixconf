{
  nixpkgs-unstable,
  home-manager,
  ...
}: let
  username = "alex";
in {
  imports = [
    (import ./system.nix {
      inherit username;
    })

    ./env.nix

    (import ./home {
      inherit username;
      inherit nixpkgs-unstable;
      inherit home-manager;
    })
  ];
}
