{ config, pkgs, ... }:
{
  system.copySystemConfiguration = true;
  boot.blacklistedKernelModules = [ "mei_me" ];
  imports = [
    <nixos-hardware/lenovo/thinkpad/x1/6th-gen/QHD>
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sol"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget git mkpasswd neovim dmidecode
  ];
  
  environment.shellAliases = {
    vim = "nvim";
  };
  
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

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  
  # Enable brightness control.
  programs.light.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    extraUsers.shazow = {
      isNormalUser = true;
      home = "/home/shazow";
      description = "Andrey Petrov";
      extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager"];
      uid = 1000;
      hashedPassword = let hashedPassword = import ./.hashedPassword.nix; in hashedPassword; # Make with mkpasswd
    };
    mutableUsers = false;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
