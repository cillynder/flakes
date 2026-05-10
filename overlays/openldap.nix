self: super: {
  # openldap i686 fails checks
  # issue: https://github.com/NixOS/nixpkgs/issues/514113
  # workaround: https://github.com/NixOS/nixpkgs/issues/513245#issuecomment-4320293674
  # fix: https://github.com/NixOS/nixpkgs/pull/515956
  openldap = super.openldap.overrideAttrs {
    doCheck = !self.stdenv.hostPlatform.isi686;
  };
}
