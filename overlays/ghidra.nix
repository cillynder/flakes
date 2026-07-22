self: super: {
  ghidra = super.ghidra.overrideAttrs (o: {
    postInstall = ''
      substituteInPlace $out/lib/ghidra/support/launch.properties \
        --replace "-Dsun.java2d.uiScale=1" "-Dsun.java2d.uiScale=2"
    '';
  });
  ghidra-bin = super.ghidra-bin.overrideAttrs (o: {
    postFixup = o.postFixup + ''
      substituteInPlace $out/lib/ghidra/support/launch.properties \
        --replace "-Dsun.java2d.uiScale=1" "-Dsun.java2d.uiScale=2"
    '';
  });
}
