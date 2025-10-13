# Screen locking configuration for Wayland
{ pkgs, lib, ... }:

{
  programs.swaylock = {
    enable = true;
    settings = {
      color = lib.mkDefault "000000";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };

  systemd.user.services.wayland-lock = {
    Unit = {
      Description = "Lock the screen for Wayland";
      # Can activate with `systemctl --user start lock.target`
      PartOf = [ "lock.target" ];
      Before = [ "sleep.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
      OnSuccess = [ "unlock.target" ];
    };

    Service = {
      Type = "forking";
      ExecStart = "${pkgs.swaylock}/bin/swaylock --daemonize";
    };

    Install = {
      WantedBy = [ "lock.target" "sleep.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    };
  };
}

