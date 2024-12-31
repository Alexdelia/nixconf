{
  imports = [../../system];

  # TODO: set in `system/de`
  stylix.enable = true;

  hostOption = {
    type = "lite";

    entertainment = {
      music = true;
      video = true;
      gaming = true;
    };
  };

  # TODO: move to `system/bluetooth.nix`
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # TODO: move to `system/boot.nix`
  # `system/boot.nix` will need an option for the device
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
}
