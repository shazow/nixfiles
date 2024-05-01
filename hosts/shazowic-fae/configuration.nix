{
  pkgs,
  lib,
  ...
}: {
  boot.layout.enable = true;

  imports = [
    ../../hardware/framework-13-amd.nix

    ../../common/desktop-i3.nix

    ../../common/users.nix
    ../../common/crypto.nix
  ];

  # Palm rejection during typing for x11
  services.xserver.libinput.touchpad.disableWhileTyping = true;

  # Disable tailscale from starting by default, it's fairly noisy and may be impacting battery life
  systemd.services.tailscaled.wantedBy = lib.mkForce [ ];

  environment.systemPackages = with pkgs; [
    ectool # Embedded controller tool (battery charge limit, etc.)

    # Wireless
    iw # wireless tooling
    crda # wireless regulatory agent
    wireless-regdb
  ];
}
