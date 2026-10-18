{
  imports = [
    ../../system
    ../../system/zram.nix
  ];

  hostOption = {
    type = "lite";

    spec = {
      laptop = true;
    };

    entertainment = {
      music = true;
      video = true;
      gaming = true;
    };
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}
