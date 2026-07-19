{
  "99-bluez" = import ./bluez.nix;
  "98-alsa" = import ./alsa.nix;

  "90-default-target" = {
    "wireplumber.settings"."node.restore-default-targets" = false;
  };
}
