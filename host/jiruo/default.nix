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
    type = "lite";

    spec = {
      monitor = {
        "DP-1" = {
          width = 2560;
          height = 1440;
          refresh = "144.003";
          x = 0;
          y = 0;
          primary = true;
          adaptiveSync = true;
        };

        "HDMI-A-1" = {
          width = 1920;
          height = 1080;
          x = 2560;
          y = 0;
          media = true;
        };
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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
}
