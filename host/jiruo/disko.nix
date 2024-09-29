{lib, ...}: {
  fileSystems = {
    "/".device = lib.mkForce "/dev/disk/by-partlabel/root";
    "/boot".device = lib.mkForce "/dev/disk/by-partlabel/ESP";
  };

  disko.devices = {
    disk = {
      ssd = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            bios = {
              type = "EF02"; # BIOS boot partition
              size = "2M";
            };
            ESP = {
              type = "EF00"; # EFI System Partition
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      hdd = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/hdd";
              };
            };
          };
        };
      };
    };
  };
}
