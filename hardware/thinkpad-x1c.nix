{ config, pkgs, lib, ... }:

{
  hardware.cpu.intel.updateMicrocode = true;

  # Backport from <nixos-hardware/lenovo/thinkpad/x1/6th-gen/QHD>
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  # Fix sizes of GTK/GNOME ui elements
  #environment.variables = {
  #  GDK_SCALE = lib.mkDefault "2";
  #  GDK_DPI_SCALE= lib.mkDefault "0.5";
  #};

  fonts.fontconfig.dpi = 210;
  services.xserver.dpi = 210;

  services.xserver.monitorSection = ''
    DisplaySize 310 174   # In millimeters
  '';

  services.xserver.deviceSection = ''
    Driver "intel"
    Option "TearFree" "true"
    Option "DRI" "3"
    Option "Backlight" "intel_backlight"
  '';

  services.xserver.libinput = {
    enable = true;
    disableWhileTyping = true;
    accelSpeed = "0.25";
    clickMethod = "clickfinger";
  };

  services.tlp.enable = true;
  services.tlp.extraConfig = ''
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
