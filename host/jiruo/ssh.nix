{ users, ... }:
{
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    openFirewall = false;

    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AuthenticationMethods = "publickey";

      AllowUsers = users;
      MaxAuthTries = 3;
      LoginGraceTime = 20;

      AllowTcpForwarding = "no";
      AllowAgentForwarding = "no";
      GatewayPorts = "no";
      PermitTunnel = "no";
    };
  };

  users.users.alex.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+6tkcPV1BuC/+P2pVvyxQB9kL5zIJAUx7Fe5l5ixQq alex@work"
  ];

  networking = {
    nftables.enable = true;

    firewall.extraInputRules = ''
      ip saddr 192.168.1.0/24 tcp dport 22 accept
    '';
  };
}
