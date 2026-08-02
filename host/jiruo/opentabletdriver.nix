{ lib, ... }: {
  hardware.opentabletdriver.enable = true;

  systemd.user.services.opentabletdriver.wantedBy = lib.mkForce [ ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="28bd", ATTR{idProduct}=="0075", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="opentabletdriver.service"
  '';
}
