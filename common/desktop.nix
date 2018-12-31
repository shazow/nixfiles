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
    wget git mkpasswd neovim dmidecode unzip gnumake
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
  hardware.pulseaudio.enable = true;
  programs.light.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.enable = true;
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.windowManager.i3.enable = true;
  sound.enable = true;
}
