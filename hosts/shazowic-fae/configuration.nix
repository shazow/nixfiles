{
  pkgs,
  pkgs-unstable,
  lib,
  initialHashedPassword,
  ...
}: {
  imports = [
    ../../hardware/framework-13-amd.nix

    ../../modules/bootlayout.nix

    ../../modules/users.nix

    ../../common/desktop-wayland.nix

    ../../common/crypto.nix
  ];

  nixfiles.bootlayout = {
    enable = lib.mkDefault true;
  };

  nixfiles.users = {
    enable = true;
    inherit initialHashedPassword;
  };

  # FIXME: Can switch back to pkgs.* when https://nixpk.gs/pr-tracker.html?pr=496567 is backported:
  boot.kernelPackages = pkgs-unstable.linuxPackages_latest;

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
