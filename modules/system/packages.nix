{ pkgs, ... }: {
  imports = [ ./packages-gui.nix ];
  environment.systemPackages = with pkgs; [
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
    ripgrep
    rsync
    sshfs
    wget
  ];
  environment.variables.EDITOR = "nvim";
}
