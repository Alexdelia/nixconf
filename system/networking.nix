{hostname, ...}: {
  networking = {
    hostName = hostname;

    networkmanager.enable = true;

    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    /*
    proxy = {
      default = "http://user:password@proxy:port/";
      noProxy = "127.0.0.1,localhost,internal.domain";
    };
    */

    /*
    firewall = {
      # enable = true / false;

      # allowedTCPPorts = [ ... ];
      # allowedUDPPorts = [ ... ];
    };
    */
  };
}
