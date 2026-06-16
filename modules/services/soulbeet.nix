{ ... }:
let
  dir_data = "/persist/services/soulbeet/data";
  dir_downloads = "/persist/containers/fluorite/slskd/downloads";
  dir_music = "/persist/media/music";
in {
  systemd.tmpfiles.rules = [
    "d ${dir_data} 700 root root"
    "d ${dir_downloads} 755 root users"
    "d ${dir_music} 075 nobody users"
  ];
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    container-name = {
      image = "docker.io/docccccc/soulbeet:latest";
      autoStart = true;
      ports = [ "9765:9765" ];
      environment = {
        DATABASE_URL = "sqlite:/data/soulbeet.db";
        DOWNLOAD_PATH = "/downloads";
        SECRET_KEY = "change-me-in-production";
        NAVIDROME_URL = "http://navidrome:4533";
        BEETS_CONFIG = "/config/config.yaml";
      };
      volumes = [
        "${dir_data}:/data"
        "${dir_downloads}:/downloads"
        "${dir_music}:/music"
      ];
    };
  };
}
