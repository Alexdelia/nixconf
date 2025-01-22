{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
  ];

  /*
  fileSystems = {
    "/".device = lib.mkForce "/dev/disk/by-partlabel/root";
    "/boot".device = lib.mkForce "/dev/disk/by-partlabel/ESP";
  };
  */

  disko.devices = {
    disk = {
      ssd-nvme = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_4TB_S7HRNJ0X107165P";
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
              size = "2G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
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

      ssd-sata = {
        device = "/dev/disk/by-id/ata-ST2000DM001-1ER164_Z4Z3RSTY";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            swap = {
              size = "100%";
              content = {
                type = "swap";
              };
            };
          };
        };
      };

      hdd = {
        device = "/dev/disk/by-id/ata-Crucial_CT500MX200SSD1_15451100FC43";
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
