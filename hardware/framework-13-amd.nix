{ pkgs, lib, ... }:
{
  # TODO: Not sure if this is necessary, but trying it out
  # https://community.frame.work/t/tracking-ppd-v-tlp-for-amd-ryzen-7040/39423/27
  boot.kernelParams = [
    "amd_pstate=active"
    # Removed: "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.sg_display=0"
    "cpufreq.default_governor=powersave"
    "initcall_blacklist=cpufreq_gov_userspace_init,cpufreq_gov_performance_init"
    "pcie_aspm=force"
    "pc"
    "ie_aspm.policy=powersupersave"
  ];
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

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  powerManagement.powertop.enable = true; # Run powertop on boot

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # Not needed, use mesa driver by default: services.xserver.videoDrivers = [ "amdgpu" ];
  services.blueman.enable = true;
  services.fprintd.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;

  services.fwupd.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ]; # Some framework firmware is still in testing
}
