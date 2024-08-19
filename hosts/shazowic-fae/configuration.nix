{
  pkgs,
  lib,
  disk,
  initialHashedPassword,
  ...
}: {
  imports = [
    ../../hardware/framework-13-amd.nix

    #../../common/desktop-i3.nix
    ../../common/desktop-wayland.nix

    ../../common/crypto.nix

    ../../modules/users.nix

    (import ../../common/boot.nix {
        inherit disk;
    })
  ];

  nixfiles.users = {
    enable = true;
    inherit initialHashedPassword;
  };

  # Palm rejection during typing for x11
  services.libinput.touchpad.disableWhileTyping = true;

  # Disable tailscale from starting by default, it's fairly noisy and may be impacting battery life
  systemd.services.tailscaled.wantedBy = lib.mkForce [ ];

  environment.systemPackages = with pkgs; [
    ectool # Embedded controller tool (battery charge limit, etc.)

    # Wireless
    iw # wireless tooling
    wireless-regdb
  ];

  networking.firewall.allowedTCPPorts = [
    8010 # VLC Chromecast
    2022 # SSH Chat debugging
  ];

  # Boot with bluetooth powered off?
  #hardware.bluetooth.powerOnBoot = false;

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "24.05";
}
