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

    ./font.nix

    (import ./home {
      inherit username;
      inherit nixpkgs-unstable;
      inherit home-manager;
    })
  ];
}
