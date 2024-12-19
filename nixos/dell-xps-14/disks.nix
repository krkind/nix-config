{ disks ? [ "/dev/disk/by-path/pci-0000:00:12.7-scsi-0:0:0:0" ], ... }:
{
  disko.devices = {
    disk = {
      nvme = {
        device = "/dev/disk/by-path/pci-0000:00:12.7-scsi-0:0:0:0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
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
    };
  };
}
