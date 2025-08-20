# Example of how to integrate the niri.nix module into your home.nix
# This is just an example - adapt it to your actual home-manager setup

{ config, pkgs, ... }:

let
  # Get niri from unstable since it's not in stable yet
  pkgs-unstable = import <nixpkgs-unstable> { 
    inherit (pkgs) system; 
    config = pkgs.config; 
  };
in
{
  # Import the niri configuration
  imports = [
    ./config/niri.nix
  ];

  # Add niri package from unstable
  home.packages = with pkgs; [
    # Regular stable packages
    firefox
    alacritty
    rofi-wayland
    
    # Niri from unstable
    pkgs-unstable.niri
  ];

  # Other home-manager configuration...
  programs.git = {
    enable = true;
    # ... git config
  };
  
  # If you want to disable sway when using niri
  # wayland.windowManager.sway.enable = false;
}
