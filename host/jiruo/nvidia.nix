{
  hostOption.spec.nvidia = true;

  hardware.graphics = {
    enable = true;

    enable32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    branch = "stable";

    # Modesetting is required.
    modesetting.enable = true;

    powerManagement = {
      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      finegrained = false;
    };

    # https://wiki.nixos.org/wiki/NVIDIA
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # might enable for CUDA kernel https://github.com/Alexdelia/puzzle compute
    # nvidiaPersistenced = true;
  };
}
