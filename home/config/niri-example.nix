# Example of how to integrate the niri.nix module into your home.nix
# This is just an example - adapt it to your actual home-manager setup

{ config, pkgs, ... }:

let
  # Niri is now available in stable nixpkgs
in
{
  # Import the niri configuration
  imports = [
    ./config/niri.nix
  ];

  # Add niri package from stable nixpkgs
  home.packages = with pkgs; [
    # Regular stable packages
    firefox
    alacritty
    rofi-wayland
    
    # Niri from stable nixpkgs
    niri
  ];

  # Other home-manager configuration...
  programs.git = {
    enable = true;
    # ... git config
  };
  
  # If you want to disable sway when using niri
  # wayland.windowManager.sway.enable = false;
}
