{
  system,
  ilib,
  ...
}: let
  users = [
    "alex"
  ];

  stateVersion = "24.05";
in
  ilib.mkNixosConfigurations {inherit system users stateVersion;}
