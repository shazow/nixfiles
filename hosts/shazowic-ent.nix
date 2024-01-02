{ inputs, ... }:
{
  system = "x86_64-linux";

  modules = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd

    ../modules/bootlayout.nix
  ];

  home = [
    ../home/desktop.nix
  ];

  # NixOS root configuraiton, this can live in a separate file if you prefer:
  # root = import ./configuration.nix;
  root = {
    pkgs, lib,
    inputs,
    primaryUsername,
    initialHashedPassword,
    ...
  }: {
    boot.layout.enable = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    # $ sudo nixos-generate-config --show-hardware-config | grep -i kernel
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.kernelModules = [ "kvm-amd" ];

    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

    imports = [
      ../common/desktop-i3.nix
      ../common/crypto.nix
      ../common/guest.nix
      ../common/tracy.nix
    ];

    # Hardware specific
    hardware.cpu.amd.updateMicrocode = true;
    hardware.enableRedistributableFirmware = true;
    hardware.steam-hardware.enable = true; # VR
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = [
        pkgs.rocmPackages.clr.icd
        pkgs.amdvlk
        # Encoding/decoding acceleration
        pkgs.libvdpau-va-gl
        pkgs.vaapiVdpau
      ];
      extraPackages32 = [
        pkgs.driversi686Linux.amdvlk
      ];
    };
    hardware.i2c.enable = true; # For controlling displays with ddcutil
    # Not needed, use mesa driver by default: services.xserver.videoDrivers = [ "amdgpu" ];
    services.xserver.dpi = 163; # 3840x2160 over 27"
    services.fwupd.enable = true;
    services.blueman.enable = true;
    hardware.bluetooth.enable = true;

    services.openssh = {
      enable = true;
      startWhenNeeded = true; # Don't start until socket request comes in to systemd
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    environment.systemPackages = with pkgs; [
      home-manager

      # Desktop
      alsa-tools
      arandr
      colord
      dunst
      feh
      libnotify
      maim
      openvpn
      pavucontrol

      # Apps
      gnupg

      # Other
      android-udev-rules
      alsa-firmware

      # Wireless
      iw # wireless tooling
      crda # wireless regulatory agent
      wireless-regdb
    ];

    networking.hostName = "shazowic-ent";
    networking.networkmanager.wifi.backend = "iwd";
    networking.networkmanager.wifi.macAddress = "permanent"; # One of "preserve", "random", "stable", "permanent", "00:11:22:33:44:55"


    virtualisation.docker = {
      enable = true;
      enableOnBoot = false; # Started on-demand by docker.socket
    };

    users.users.${primaryUsername} = {
      isNormalUser = true;
      home = "/home/${primaryUsername}";
      extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager" "plugdev" "dialout" "adbusers" "docker" "i2c" ];
      uid = 1000;
      initialHashedPassword = initialHashedPassword;
    };

    # Agent daemon required for pinentry
    programs.gnupg.agent.enable = true;

    # Android dev
    programs.adb.enable = true;
  };
}
