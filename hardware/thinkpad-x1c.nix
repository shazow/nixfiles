{ config, pkgs, lib, ... }:

{
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true; # Might help wifi?

  # Backport from <nixos-hardware/lenovo/thinkpad/x1/6th-gen/QHD>
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  # Fix sizes of GTK/GNOME ui elements
  #environment.variables = {
  #  GDK_SCALE = lib.mkDefault "2";
  #  GDK_DPI_SCALE= lib.mkDefault "0.5";
  #};

  services.xserver.dpi = 210; # 210 is the native DPI of the HDR screen
  fonts.fontconfig.dpi = 140; # This is Xft.dpi in .Xresources, 140 = 210 / 1.5

  services.xserver.monitorSection = ''
    DisplaySize 310 174   # In millimeters
  '';

  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
    Option "Backlight" "intel_backlight"  # Maybe unnecessary?

    # DRI 2 is the old trusty workhorse. Nice to fall back to if there are
    # rendering bugs.
    #Option "DRI" "2"

    # DRI 3 with default AccelMethod causes rendering issues after sleep/resume
    # with some GPU-accelerated 2D apps (like Electron/Alacritty). It does work
    # with the older "UXA" AccelMethod, but there's a 1-2s lag switching
    # desktops to Chrome. Upside is DRI 3 has better Vulkan support?
    Option "DRI" "3"
    Option "AccelMethod" "UXA"  # Default is the newer "SNA", see note above.
    Option "TearFree" "true"
  '';

  services.xserver.libinput = {
    enable = true;
    disableWhileTyping = true;
    accelSpeed = "0.25";
    clickMethod = "clickfinger";
  };

  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    CPU_SCALING_GOVERNOR_ON_AC=powersave
    CPU_SCALING_GOVERNOR_ON_BAT=powersave
    START_CHARGE_THRESH_BAT0=75
    STOP_CHARGE_THRESH_BAT0=90
    DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"
    DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE="bluetooth"
  '';

  # Firmware updating
  services.fwupd.enable = true;

  # Disable the "throttling bug fix" -_- https://github.com/NixOS/nixos-hardware/blob/master/common/pc/laptop/cpu-throttling-bug.nix
  systemd.timers.cpu-throttling.enable = lib.mkForce false;
  systemd.services.cpu-throttling.enable = lib.mkForce false;
}
