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

  home.packages = with pkgs; [
    # TODO: Use systemd-lock-handler somehow?  https://git.sr.ht/~whynothugo/systemd-lock-handler
    # Handles porting over correct events from sleep into lock/unlock.
    #systemd-lock-handler
  ];

  #systemd.user.services.systemd-lock-handler.wantedBy = [ "default.target" ];


  systemd.user.services.wayland-lock = {
    Unit = {
      # Skip starting this when doing a switch
      X-SwitchMethod = "keep-old";
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

  systemd.user.targets.lock.Unit.Description = "Lock the screen";
  systemd.user.targets.unlock.Unit.Description = "Screen is unlocked";
}

