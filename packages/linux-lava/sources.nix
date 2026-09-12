{ fetchFromGitHub, inputs, lib }:
let
  version = "7.2.5";
  kernelHash = "1cq2jj1g06gav6xvbxfb1l5jlp43b52ffjvg08ckix8d9k8z7zpr";
  kernelPatchHash = "1gg52gmc7br9089737f40hpa7ym4myxh64fbj767a7sl09yqqf8j";

  mm = lib.versions.majorMinor version;
  hasPatch = (builtins.length (builtins.splitVersion version)) == 3;
  tkgPatches = [
    "0002-clear-patches"
    "0003-glitched-base"
    "0001-bore"
    "0003-glitched-cfs"
    "0012-misc-additions"
  ];

  patch = path: {
    name = "patch-${path}";
    patch = path;
  };
  kernelPatchSrc = {
    name = "patch";
    patch = builtins.fetchurl {
      url = "https://cdn.kernel.org/pub/linux/kernel/v${lib.versions.major version}.x/patch-${version}.xz";
      sha256 = kernelPatchHash;
    };
  };
in {
  inherit version;

  src = builtins.fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v${lib.versions.major version}.x/linux-${mm}.tar.xz";
    sha256 = kernelHash;
  };

  kernelPatches = lib.optionals hasPatch [
    kernelPatchSrc
    (patch ./bluetooth.patch)
  ]
  ++ builtins.map (name: {
    inherit name;
    patch = "${inputs.linux-tkg}/linux-tkg-patches/${mm}/${name}.patch";
  }) tkgPatches
  ++ [ ];
}
