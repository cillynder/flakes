# https://github.com/NixOS/nixpkgs/issues/375254
self: super: {
  jetbrains = super.jetbrains // {
    gateway = let
      unwrapped = super.jetbrains.gateway;
    in super.buildFHSEnv {
      name = "gateway";
      inherit (unwrapped) version;

      runScript = super.writeScript "gateway-wrapper" ''
        unset JETBRAINS_CLIENT_JDK
        exec ${unwrapped}/bin/gateway "$@"
      '';

      meta = unwrapped.meta;

      passthru = {
        inherit unwrapped;
      };
    };
  };
}
