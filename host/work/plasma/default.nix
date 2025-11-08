{...}: {
  imports = [
    ./font.nix
    ./keybind.nix
    # ./touchpad.nix
    ./screenlocker.nix
  ];

  programs = {
    plasma = {
      enable = true;
    };
  };
}
