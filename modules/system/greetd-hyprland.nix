{ pkgs, ... }: {
  programs.hyprland.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember --asterisks --time --cmd 'niri-session'";
        user = "greeter";
      };

      initial_session = {
        command = "start-hyprland";
        user = "rin";
      };
    };
  };
}
