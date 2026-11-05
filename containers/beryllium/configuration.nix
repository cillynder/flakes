{ config, pkgs, ports, ... }:
let
  keyFile = "/run/livekit.key";
  mautrixDataDir = "/persist/mautrix-discord";
in {
  system.stateVersion = "25.11";
  fileSystems."/var/lib/private" = {
    device = "/persist";
    fsType = "none";
    options = [ "bind" ];
  };
  networking.firewall.allowedTCPPorts = [ ports.continuwuity ports.livekitRtc ports.livekitJwt ports.livekit ];
  # TODO: this should be generically set
  networking.useHostResolvConf = false;
  # TODO: link this with outer container's address
  networking.nameservers = [ "10.30.2.1" ];

  services.matrix-continuwuity = {
    enable = true;
    settings.global = {
      # TODO: link this with outer container's address
      address = [ "10.30.2.2" ];
      port = [ ports.continuwuity ];
      max_request_size = 500 * 1024 * 1024;
      server_name = "qtnet.work";
      allow_registration = true;
      url_preview_domain_explicit_allowlist = [ "*" ];
      url_preview_allow_audio_video = true;

      matrix_rtc = {
        foci = [{
          type = "livekit";
          livekit_service_url = "https://livekit.qtnet.work";
        }];
      };
    };
  };

  # LiveKit
  services.livekit = {
    enable = true;
    openFirewall = true;
    settings = {
      room.auto_create = false;
      port = ports.livekit;
      bind_addresses = [ "10.30.2.2" ];
      rtc = {
        tcp_port = ports.livekitRtc;
        port_range_start = ports.livekitStart;
        port_range_end = ports.livekitEnd;
        use_external_ip = true;
        enable_loopback_candidate = false;
      };
    };
    inherit keyFile;
  };
  services.lk-jwt-service = {
    enable = true;
    livekitUrl = "wss://livekit.qtnet.work";
    port = ports.livekitJwt;
    inherit keyFile;
  };
  systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = "qtnet.work";

  # LiveKit/Keygen
  systemd.services.livekit-key = {
    before = [ "lk-jwt-service.service" "livekit.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ livekit coreutils gawk ];
    script = ''
      echo "Key missing, generating key"
      echo "lk-jwt-service: $(livekit-server generate-keys | tail -1 | awk '{print $3}')" > "${keyFile}"
    '';
    serviceConfig.Type = "oneshot";
    unitConfig.ConditionPathExists = "!${keyFile}";
  };

  # mautrix-discord
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
  services.mautrix-discord = {
    enable = true;
    dataDir = mautrixDataDir;
    environmentFile = "/binds/mautrix_discord_env";
    settings = {
      homeserver = {
        address = "https://beryllium.qtnet.work";
        domain = "qtnet.work";
      };
      bridge.direct_media = {
        enabled = true;
        serverName = "md-proxy.qtnet.work";
        serverKey = "$MD_DM_KEY";
      };
      bridge.permissions = {
        "qtnet.work" = "user";
        "@cilly:qtnet.work" = "admin";
      };
      appservice = {
        address = "http://localhost:${toString ports.mautrixDiscord}";
        hostname = "0.0.0.0";
        port = ports.mautrixDiscord;

        database.uri = "file:${mautrixDataDir}/mautrix-discord.db?_txlock=immediate";
      };
    };
  };
  systemd.services.mautrix-discord = {
    wants = [ "network-online.target" "continuwuity.service" ];
    after = [ "network-online.target" "continuwuity.service" ];
  };
}
