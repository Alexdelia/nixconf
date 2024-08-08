{lib, ...}: {
  programs = {
    kitty = {
      enable = true;

      font = lib.mkForce {
        name = "RobotoMono Nerd Font";
        size = 14;
      };
    };
  };
}
