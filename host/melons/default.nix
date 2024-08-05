{
  hostname,
  ilib,
  ...
}: let
  users = [
    "alex"
  ];

  system = "x86_64-linux";

  stateVersion = "24.05";
in
  ilib.mkNixosConfigurations {inherit hostname system users stateVersion;}
