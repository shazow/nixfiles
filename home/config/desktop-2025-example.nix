# Example of how to use the Desktop 2025 Edition
# This replaces the old Sway-based setup with modern Wayland components

{ config, pkgs, ... }:

{
  # Import the complete Desktop 2025 Edition
  imports = [
    ./config/desktop-2025.nix
  ];

  # Your other home-manager configuration...
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };
  
  programs.firefox.enable = true;
  
  # Optional: Disable the old Sway setup if it was previously enabled
  # wayland.windowManager.sway.enable = false;
  
  # Desktop 2025 Edition provides:
  # - Niri (scrollable-tiling compositor) instead of Sway
  # - Waybar (status bar) instead of i3status-rust  
  # - Wezterm (terminal) instead of Alacritty
  # - Fuzzel (launcher) instead of Rofi
  # - Consistent theming via stylix/GTK
  # - Modern notification system with dunst
  
  home.stateVersion = "23.05"; # Adjust to your actual state version
}
