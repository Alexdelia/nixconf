{
  host,
  system,
  inputs,
  ilib,
  ...
}: let
  users = [
    "alex"
  ];

  stateVersion = "23.11";
in {
  homeConfigurations = (
    builtins.map (
      username: ilib.mkStandaloneHome {inherit username system stateVersion;}
    )
    users
  );
}
