{
  pkgs,
  lib,
  initialHashedPassword,
  ...
}: {
  imports = [
    ../../hardware/framework-13-amd.nix

    #../../common/desktop-i3.nix
    ../../common/desktop-wayland.nix

    ../../common/crypto.nix

    ../../modules/users.nix
  ];

  nixfiles.users = {
    enable = true;
    inherit initialHashedPassword;
  };

  # Palm rejection during typing for x11
  #services.libinput.touchpad.disableWhileTyping = true;

  # Disable tailscale from starting by default, it's fairly noisy and may be impacting battery life
  systemd.services.tailscaled.wantedBy = lib.mkForce [ ];

  # Battery dbus interface
  services.upower.enable = true;

  environment.systemPackages = with pkgs; [
    framework-tool # Embedded controller tool (battery charge limit, etc.), replaces ectool

    # Wireless
    iw # wireless tooling
    wireless-regdb
  ];

  networking.hostName = "shazowic-fae";
  networking.firewall.allowedTCPPorts = [
    8010 # VLC Chromecast
    7000 # VLC Airplay
  ];

  # Boot with bluetooth powered off?
  #hardware.bluetooth.powerOnBoot = false;

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "25.05";
}
