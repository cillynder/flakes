{ fetchFromGitHub, inputs, lib }:
let
  version = "6.19";
  kernelHash = "0mqka8ii7bvmx9hvfjdiyva9ib0j7m390gxhh8gki3qb4nl7jc1h";
  kernelPatchHash = "0w36sxwwhfqpc1if9d52rg0g1k20xjl2cairlyiyk10ns17mjxlb";

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
