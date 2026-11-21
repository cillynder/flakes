self: super: let
  # TODO: bump this
  llvmPackages = super.llvmPackages_19;
  clangVersion = super.lib.versions.major llvmPackages.libclang.version;
  addFlagsScript = "$out/nix-support/add-local-cc-cflags-before.sh";
  cc = llvmPackages.stdenv.cc.override {
    # :sob: see https://github.com/NixOS/nixpkgs/issues/142901
    bintools = llvmPackages.bintools;

    # https://github.com/NixOS/nixpkgs/issues/368850
    extraBuildCommands = ''
      cat <(echo "NIX_CC_WRAPPER_SUPPRESS_TARGET_WARNING=1") "${addFlagsScript}" > "${addFlagsScript}.new"
      mv "${addFlagsScript}.new" "${addFlagsScript}"
      substituteInPlace "$out/nix-support/cc-cflags" --replace " -nostdlibinc" ""
      echo " -resource-dir=${llvmPackages.libclang.lib}/lib/clang/${clangVersion}" >> $out/nix-support/cc-cflags
    '';
  };
  stdenv = super.overrideCC llvmPackages.stdenv cc;
  ccacheStdenv = super.ccacheStdenv.override { inherit stdenv; };
in {
  linuxLavaEnv = {
    inherit llvmPackages clangVersion cc stdenv ccacheStdenv;
  };
  rust-bindgen-unwrapped = super.rust-bindgen-unwrapped.overrideAttrs(o: {
    preConfigure = ''
      export LIBCLANG_PATH="${super.lib.getLib cc.cc}/lib"
    '';
    nativeCheckInputs = [ cc ];
    passthru = {
      clang = cc;
    };
  });
}
