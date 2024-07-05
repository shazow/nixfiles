{ pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # $ nixos-generate-config --show-hardware-config
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  # Workaround for nix-hardware module
  hardware.framework.amd-7040.preventWakeOnAC = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl = {
    enable = true;
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

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  powerManagement.powertop.enable = true; # Run powertop on boot
  systemd.services.battery-limit.postStart = ''
    ${pkgs.ectool}/bin/ectool fwchargelimit 85
  '';

  # Not needed, use mesa driver by default: services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.fprintd.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;

  services.fwupd.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ]; # Some framework firmware is still in testing
}
