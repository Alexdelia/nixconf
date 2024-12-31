{
  imports = [../../system];

  hostOption = {
    type = "lite";

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
  services.blueman.enable = true;
}
