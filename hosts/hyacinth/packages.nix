{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    jetbrains.idea
    texliveFull
  ];
}
