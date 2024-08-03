{
  # host,
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
  homeConfigurations = builtins.listToAttrs (
    map
    (username: {
      name = username;
      value = (ilib.mkStandaloneHome {inherit username system stateVersion;}).${username};
    })
    users
  );
}
