{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    htop
    jq
    neovim
    rsync
    sshfs
    wget

    kitty.terminfo
  ];
  environment.variables.EDITOR = "nvim";
}
