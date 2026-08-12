#!/usr/bin/env -S nix shell 'nixpkgs#git' 'nixpkgs#curl' -c bash

update_kernel() {
    previous_ver=$(cat packages/linux-lava/sources.nix | grep "version =" | sed --expression='s/[^0-9.]//g')
    kernel_ver=$(curl -s https://www.kernel.org/finger_banner | grep -m1 stable | awk '{print $NF}')

    if [ "$previous_ver" = "$kernel_ver" ]; then
        return
    fi

    kernel_major=$(cut -d '.' -f 1 <<< "$kernel_ver")
    kernel_mmver=$(cut -d '.' -f 1,2 <<< "$kernel_ver")

    hash_mm=$(nix-prefetch-url "https://cdn.kernel.org/pub/linux/kernel/v${kernel_major}.x/linux-${kernel_mmver}.tar.xz")
    hash_patch=$(nix-prefetch-url "https://cdn.kernel.org/pub/linux/kernel/v${kernel_major}.x/patch-${kernel_ver}.xz")

    sed -i "/version =/c\  version = \"${kernel_ver}\";" packages/linux-lava/sources.nix
    sed -i "/kernelHash =/c\  kernelHash = \"${hash_mm}\";" packages/linux-lava/sources.nix
    sed -i "/kernelPatchHash =/c\  kernelPatchHash = \"${hash_patch}\";" packages/linux-lava/sources.nix

    git add packages/linux-lava/sources.nix
    git commit -m "packages/linux-lava: bump to ${kernel_ver}"
}

bump_inputs() {
    for con in ./containers/*/; do
        cd $con
        nix flake update
        git add flake.lock
        cd -
    done

    nix flake update
    git add flake.lock

    git commit -m "flake: bump inputs"
}

bump_inputs
update_kernel
