{ pkgs, lib, ... }:
{
  # $ nixos-generate-config --show-hardware-config
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  # Workaround for nix-hardware module
  hardware.framework.amd-7040.preventWakeOnAC = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.rocmPackages.clr.icd
      # Encoding/decoding acceleration
      pkgs.libvdpau-va-gl
      pkgs.libva-vdpau-driver
    ];
    extraPackages32 = [
    ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  powerManagement.powertop.enable = true; # Run powertop on boot

  # This is obsolete with the latest firmware:
  # systemd.services.battery-limit.serviceConfig.ExecStart = "${pkgs.ectool}/bin/ectool fwchargelimit 85"; # Limit battery charge to 85% on boot

  # Not needed, use mesa driver by default: services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.fprintd.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;

  # Rename Framework laptop built-in speakers in PipeWire/WirePlumber.
  # Check with: `wpctl status` (or `pw-cli ls Node`) if the node name changes.
  services.pipewire.wireplumber.extraConfig.framework-audio-rename = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "node.name" = "alsa_output.pci-0000_c1_00.6.analog-stereo";
          }
        ];
        actions = {
          update-props = {
            "node.description" = "Framework Audio";
          };
        };
      }
    ];
  };

  services.fwupd.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ]; # Some framework firmware is still in testing
}
