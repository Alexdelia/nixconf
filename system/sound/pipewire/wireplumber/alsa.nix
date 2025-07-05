{
  "monitor.alsa.rules" = [
    {
      matches = [
        {
          "node.name" = "alsa_output.pci-0000_01_00.1.hdmi-stereo";
        }
      ];
      actions = {
        "update-props" = {
          "node.nick" = "hdmi global";
          "priority.driver" = 1100;
          "priority.session" = 1100;
        };
      };
    }
    {
      matches = [
        {
          "node.name" = "alsa_output.pci-0000_00_1f.3.iec958-stereo";
        }
      ];
      actions = {
        "update-props" = {
          "node.nick" = "internal soundcard";
          "priority.driver" = 10000;
          "priority.session" = 10000;
        };
      };
    }
  ];
}
