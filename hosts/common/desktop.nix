{ pkgs, ... }:
{
  imports = [
    ./common.nix
  ];

  nixpkgs.config.allowUnfree = true;

  hardware.cpu.intel.updateMicrocode = true;
  networking.networkmanager.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget git mkpasswd neovim dmidecode
  ];

  environment.shellInit = ''
    export EDITOR=nvim
    export VISUAL=nvim

    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    (nerdfonts.override {
      withFont = "--complete FiraCode";
    })
  ];

  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # X11
  services.xserver = {
    enable = true;
    layout = "us";
  };
  services.xserver.libinput.enable = true;
  programs.light.enable = true;
}
