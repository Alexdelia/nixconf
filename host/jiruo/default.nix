{inputs, ...}: {
  imports = [
    ../../system

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./nvidia.nix
    # ./docker.nix

    ./opentabletdriver.nix
  ];

  hostOption = {
    type = "full";

    spec = {
      screen = {
        width = 2560;
        height = 1440;
      };
    };

    entertainment = {
      music = true;
      video = true;
      gaming = true;
    };
  };

  boot = {
    loader = {
      grub = {
        enable = true;
        # useOSProber = true;
        efiSupport = true;
        # efiInstallAsRemovable = true;
      };

      # systemd-boot.enable = true;
      # efi.canTouchEfiVariables = true;
    };

    # `8` = probe-order ATA port (DVD drive)
    # /!\ motherboard/CPU/GPU change can reorder ports
    # recheck number with `journalctl -b | grep ata`
    kernelParams = ["libata.force=8:disable"];
  };
}
