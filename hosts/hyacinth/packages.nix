{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    discord
    jetbrains.idea
    texliveFull
  ];
}
