{lib, ...}: {
  programs = {
    kitty = {
      enable = true;

      font = lib.mkForce {
        name = "SourceCodePro Nerd Font";
        size = 16;
      };
    };
  };
}
