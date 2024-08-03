{
  system,
  ilib,
  ...
}: let
  users = [
    "alex"
  ];

  stateVersion = "23.11";
in
  ilib.mkHomeConfigurations {inherit system users stateVersion;}
