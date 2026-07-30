{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    discord
    jetbrains.idea
    texliveFull
    gpu-screen-recorder-gtk
  ];
  programs.gpu-screen-recorder.enable = true;
}
