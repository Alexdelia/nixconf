{
  "monitor.alsa.rules" = [
    {
      matches = [
        {
          "node.name" = "bluez_output.AC_80_0A_B7_3D_F4.1";
        }
      ];
      actions = {
        "update-props" = {
          "node.nick" = "bluetooth headset";
          "priority.driver" = 10002;
          "priority.session" = 10002;
        };
      };
    }
    {
      matches = [
        {
          "node.name" = "bluez_output.1C_48_F9_16_F4_8B.1";
        }
      ];
      actions = {
        "update-props" = {
          "node.nick" = "bluetooth soundbar";
          "priority.driver" = 10001;
          "priority.session" = 10001;
        };
      };
    }
  ];
}
