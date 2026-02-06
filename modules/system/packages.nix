{ pkgs, ... }: {
  imports = [ ./packages-gui.nix ];
  environment.systemPackages = with pkgs; [
    comma
    # ecryptfs
    efibootmgr
    fd
    git
    git-crypt
    htop
    jq
    kitty.terminfo
    libarchive
    lf
    msr-tools
    ncdu
    neovim
    nfs-utils
    ntfs3g
    oci-cli
    ripgrep
    rsync
    sshfs
    wget
  ];
  environment.variables.EDITOR = "nvim";
}
