{pkgs, ...}: {
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "uinput_udev";
      text = ''
        KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
      '';
      destination = "/etc/udev/rules.d/99-uinput.rules";
    })
  ];
}
