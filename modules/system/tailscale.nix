{ config, ... }: {
  age.secrets.tailscale_auth.file = ../../secrets/tailscale_auth.age;
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale_auth.path;
    openFirewall = true;
    useRoutingFeatures = if config.me.environment == "headless" then "both" else "client";
  };
}
