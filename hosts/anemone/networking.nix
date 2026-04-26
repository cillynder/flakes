{ config, ... }: {
  networking.wireless.iwd.enable = true;
  environment.etc."NetworkManager/system-connections".source = "/persist/nm_system-connections";
}
