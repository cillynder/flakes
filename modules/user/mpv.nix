{ pkgs, ... }: {
  programs.mpv = {
    enable = true;
    package = pkgs.mpv.override {
      youtubeSupport = true;
      scripts = [ pkgs.mpvScripts.mpris ];
    };
  };
}
