{
  imports = [
    ../../system

    ./disko.nix
    ./nvidia.nix
    ./docker.nix
  ];

  hostOption = {
    type = "full";

    spec = {
      width = 2560;
      height = 1440;
    };

    entertainment = {
      music = true;
      video = true;
      gaming = true;
    };
  };

  boot.loader = {
    grub = {
      enable = true;
      # useOSProber = true;
      efiSupport = true;
      # efiInstallAsRemovable = true;
    };

    # systemd-boot.enable = true;
    # efi.canTouchEfiVariables = true;
  };
}
