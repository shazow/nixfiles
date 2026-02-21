{ pkgs
, lib
, primaryUsername
, initialHashedPassword
, disk
, ...
}: {
  # FIXME: New boot layout module is not ot fully working yet, not sure what's missing
  # Can Remove common/boot.nix after fixing.
  #nixfiles.bootlayout.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # $ sudo nixos-generate-config --show-hardware-config | grep -i kernel
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  imports = [
    ../../common/desktop-wayland.nix
    ../../common/crypto.nix
    # ../../common/tracy.nix
    (import ../../common/boot.nix {
        inherit disk;
    })
  ];

  nixpkgs.config.rocmSupport = true;

  # GPU underclocking for the 7900 XTX (`lact gui`)
  services.lact.enable = true;
  hardware.amdgpu.overdrive.enable = true;

  # Hardware specific
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.steam-hardware.enable = true; # VR
  #hardware.xpadneo.enable = true; # 8BitDo Ultimate controller wireless support # FIXME: https://github.com/NixOS/nixpkgs/issues/467164
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.rocmPackages.clr.icd
      # Encoding/decoding acceleration
      pkgs.libvdpau-va-gl
      pkgs.libva-vdpau-driver
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
    feh
    libnotify
    maim
    openvpn
    pavucontrol

    # Apps
    gnupg

    # Other
    alsa-firmware

    # Wireless
    iw # wireless tooling
    wireless-regdb
  ];

  networking.hostName = "shazowic-ent";
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.wifi.macAddress = "permanent"; # One of "preserve", "random", "stable", "permanent", "00:11:22:33:44:55"

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # Started on-demand by docker.socket
  };
  virtualisation.waydroid.enable = true; # Android emulator, for TFT
  systemd.services.waydroid-container.wantedBy = lib.mkForce []; # Disable waydroid-container start on boot

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

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "24.11";
}
