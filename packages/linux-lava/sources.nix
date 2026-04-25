{ fetchFromGitHub, inputs, lib }:
let
  version = "7.0.1";
  kernelHash = "1w4i705i0nl1xqv7fdhdbhy7j3xrzhl31fabs6vmgiw7nf06szxv";
  kernelPatchHash = "16za81aj7yzsp6magvcp3zsqjvm2l887vagmzc5dsg3wbm1c6p1p";

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
