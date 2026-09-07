{
  config,
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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Disable tailscale from starting by default, it's fairly noisy and may be impacting battery life
  systemd.services.tailscaled.wantedBy = lib.mkForce [ ];

  # Start Mullvad when the GUI or CLI connects to its management socket.
  systemd.services.mullvad-daemon = {
    wantedBy = lib.mkForce [ ];
    environment.MULLVAD_RPC_SOCKET_PATH = "/run/mullvad-vpn-backend";

    # Wait for RPC readiness before starting the proxy.
    postStart = ''
      until ${config.services.mullvad-vpn.package}/bin/mullvad status >/dev/null 2>&1; do
        sleep 0.1
      done
    '';
    serviceConfig.TimeoutStartSec = 30;
  };

  systemd.sockets.mullvad-proxy = {
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = "/run/mullvad-vpn";
      SocketMode = "0666";
      RemoveOnStop = true;
    };
  };

  systemd.services.mullvad-proxy = {
    requires = [ "mullvad-daemon.service" ];
    after = [ "mullvad-daemon.service" ];
    serviceConfig.ExecStart =
      "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd /run/mullvad-vpn-backend";
  };

  # Battery dbus interface
  services.upower.enable = true;

  # Toggle Wi-Fi power saving when the charger is plugged in or unplugged.
  # Boot/reconnect settings can override this until the next charger event.
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ACTION=="change", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${pkgs.iw}/bin/iw dev wlan0 set power_save off"
    SUBSYSTEM=="power_supply", ACTION=="change", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${pkgs.iw}/bin/iw dev wlan0 set power_save on"
  '';

  environment.systemPackages = with pkgs; [
    framework-tool # Embedded controller tool (battery charge limit, etc.), replaces ectool

    # Wireless
    iw # wireless tooling
    wireless-regdb
  ];

  networking.hostName = "shazowic-fae";
  services.avahi.publish.enable = false; # Discover other devices without advertising this host.

  networking.networkmanager.connectionConfig = {
    "ipv4.dhcp-send-hostname" = false;
    "ipv6.dhcp-send-hostname" = false;
  };

  networking.firewall.allowedTCPPorts = [
    8010 # VLC Chromecast
    7000 # VLC Airplay
  ];

  # Boot with bluetooth powered off?
  #hardware.bluetooth.powerOnBoot = false;

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "25.05";
}
