{...}: {
  imports = [
    ./font.nix
    ./keybind.nix
    # ./touchpad.nix
  ];

  programs = {
    plasma = {
      enable = true;
    };
  };
}
