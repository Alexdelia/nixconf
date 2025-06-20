{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  enable =
    config.hostOption.entertainment.gaming
    && config.hostOption.type == "full";
in {
  imports =
    if enable
    then [
      inputs.nix-minecraft.nixosModule.minecraft-servers
    ]
    else [];

  config = lib.mkIf enable {
    services.minecraft-servers = {
      inherit enable;

      eula = true;

      openFirewall = false; # closed for now

      # whitelist = {
      # Alexdelia = "TODO";
      # };

      servers.fabric = {
        inherit enable;

        package = pkgs.fabricServers.fabric-1_19_2.override {
          loaderVersion = "0.16.14";
        };

        symlinks = {
          mods = pkgs.linkFarmFromDrvs "mods" (
            builtins.attrValues {
              Fabric-API = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/9YVrKY0Z/fabric-api-0.115.0%2B1.21.1.jar";
                sha512 = "e5f3c3431b96b281300dd118ee523379ff6a774c0e864eab8d159af32e5425c915f8664b1";
              };
              Backpacks = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/MGcd6kTf/versions/Ci0F49X1/1.2.1-backpacks_mod-1.21.2-1.21.3.jar";
                sha512 = "6efcff5ded172d469ddf2bb16441b6c8de5337cc623b6cb579e975cf187af0b79291";
              };
            }
          );
        };
      };
    };
  };
}
