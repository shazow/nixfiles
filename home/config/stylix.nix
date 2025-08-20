# Stylix theming configuration
# Provides consistent theming across Desktop 2025 Edition
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Note: This requires the stylix input to be added to your flake.nix
  # Add this to your flake inputs:
  # stylix.url = "github:danth/stylix";
  
  # imports = [ inputs.stylix.homeManagerModules.stylix ];
  
  # For now, we'll create a basic theming setup without stylix dependency
  # This can be enabled later when stylix is added to the flake
  
  # Basic theming configuration for components
  home.sessionVariables = {
    # GTK theme
    GTK_THEME = "Adwaita:dark";
  };
  
  # GTK configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    
    font = {
      name = "DejaVu Sans";
      size = 10;
    };
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  
  # Qt theming
  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
  
  # Font configuration
  fonts.fontconfig.enable = true;
  
  # Common color scheme for manual theming
  # These can be used by other configuration files
  home.sessionVariables = {
    # Base16 Solarized Dark colors for consistency
    COLOR_BASE00 = "#002b36";  # base00 - background
    COLOR_BASE01 = "#073642";  # base01 - lighter background
    COLOR_BASE02 = "#586e75";  # base02 - selection background
    COLOR_BASE03 = "#657b83";  # base03 - comments
    COLOR_BASE04 = "#839496";  # base04 - dark foreground
    COLOR_BASE05 = "#93a1a1";  # base05 - foreground
    COLOR_BASE06 = "#eee8d5";  # base06 - light foreground
    COLOR_BASE07 = "#fdf6e3";  # base07 - light background
    COLOR_BASE08 = "#dc322f";  # base08 - red
    COLOR_BASE09 = "#cb4b16";  # base09 - orange
    COLOR_BASE0A = "#b58900";  # base0A - yellow
    COLOR_BASE0B = "#859900";  # base0B - green
    COLOR_BASE0C = "#2aa198";  # base0C - cyan
    COLOR_BASE0D = "#268bd2";  # base0D - blue
    COLOR_BASE0E = "#6c71c4";  # base0E - purple
    COLOR_BASE0F = "#d33682";  # base0F - magenta
  };
  
  # Cursor theme
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };
  
  # Home packages for theming support
  home.packages = with pkgs; [
    # Theming tools
    gnome.gnome-themes-extra
    gnome.adwaita-icon-theme
    adwaita-qt
    
    # Font packages
    dejavu_fonts
    font-awesome
    
    # GTK/Qt tools for debugging themes
    gtk3
    gtk4
    qt5.qttools
  ];
}

# Future Stylix configuration (commented out until added to flake):
# {
#   stylix = {
#     enable = true;
#     
#     # Base16 theme
#     base16Scheme = "${pkgs.base16-schemes}/share/themes/solarized-dark.yaml";
#     
#     # Wallpaper
#     image = ./wallpaper.jpg;  # Add your preferred wallpaper
#     
#     # Fonts
#     fonts = {
#       monospace = {
#         package = pkgs.dejavu_fonts;
#         name = "DejaVu Sans Mono";
#       };
#       sansSerif = {
#         package = pkgs.dejavu_fonts;
#         name = "DejaVu Sans";
#       };
#       serif = {
#         package = pkgs.dejavu_fonts;
#         name = "DejaVu Serif";
#       };
#       sizes = {
#         applications = 10;
#         terminal = 10;
#         desktop = 10;
#         popups = 10;
#       };
#     };
#     
#     # Cursor
#     cursor = {
#       package = pkgs.gnome.adwaita-icon-theme;
#       name = "Adwaita";
#       size = 24;
#     };
#     
#     # Target applications
#     targets = {
#       gtk.enable = true;
#       waybar.enable = true;
#       fuzzel.enable = true;
#       wezterm.enable = true;
#     };
#   };
# }
