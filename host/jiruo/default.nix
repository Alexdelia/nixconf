{
  hostname,
  users,
  stateVersion,
  ...
}: {
  imports = [
    ../../system

    # inputs.disko.nixosModules.disko
    ./nvidia.nix
    # ./disko.nix
    (import ./docker.nix {inherit users;})
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

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
    efiSupport = true;
    # efiInstallAsRemovable = true;
  };
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
