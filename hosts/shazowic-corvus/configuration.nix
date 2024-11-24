{ config
, pkgs
, lib
, initialHashedPassword
, disk
, ...
}:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];
  boot.blacklistedKernelModules = [ "mei_me" ];
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=US
    options snd_hda_intel power_save=1 power_save_controller=Y
  '';
  #hardware.enableAllFirmware = true;  # This pulls in everything, including Mac hardware etc.
  hardware.graphics.extraPackages = with pkgs; [ vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl intel-media-driver ];

  # Bluetooth
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  nix.settings.max-jobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  powerManagement.powertop.enable = true; # Run powertop --auto-tune on start

  imports = [
    ../../hardware/thinkpad-x1c.nix

    (import ../../common/boot.nix {
      inherit disk;
    })

    ../../common/crypto.nix

    #../../common/desktop-i3.nix
    ../../common/desktop-wayland.nix

    ../../modules/users.nix
  ];

  nixfiles.users = {
    enable = true;
    inherit initialHashedPassword;
  };

  networking.firewall.allowedTCPPorts = [
    8010 # VLC Chromecast
    2022 # SSH Chat debugging
  ];

  environment.systemPackages = with pkgs; [
    # Wireless
    iw # wireless tooling
    wireless-regdb
  ];

  networking.hostName = "shazowic-corvus";
  networking.search = [ "shazow.gmail.com.beta.tailscale.net" ];
  networking.resolvconf.dnsExtensionMechanism = false; # Remove edns0 option in resolv.conf: Breaks some public WiFi but it is required for DNSSEC.
  networking.networkmanager.wifi.backend = "iwd"; # "wpa_supplicant" is default
  networking.networkmanager.wifi.macAddress = "stable"; # One of "preserve", "random", "stable", "permanent", "00:11:22:33:44:55"
  networking.networkmanager.wifi.powersave = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # Started on-demand by docker.socket
  };

  # Agent daemon required for pinentry
  programs.gnupg.agent.enable = true;

  # Android dev
  programs.adb.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.05";
}
