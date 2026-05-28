{ config, lib, ... }: {
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
  };
  hardware.cpu.amd.updateMicrocode = true;
}
