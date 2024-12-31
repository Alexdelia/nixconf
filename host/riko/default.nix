{
  imports = [
    ../../system
  ];

  hostOption = {
    type = "minimal";

    entertainment = {
      music = false;
      video = false;
      gaming = false;
    };
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };
}
