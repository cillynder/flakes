{ pkgs, ... }: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember --asterisks --time --cmd 'start-hyprland'";
        user = "greeter";
      };

      initial_session = {
        command = "start-hyprland";
        user = "rin";
      };
    };
  };
}
