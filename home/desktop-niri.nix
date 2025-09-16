{ pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.niri-flake.homeManagerModules.niri
    inputs.stylix.homeManagerModules.stylix
    ../config/waybar.nix
  ];

  # Enable the new desktop environment components
  programs.waybar.enable = true;
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font("DejaVu Sans Mono"),
      }
    '';
  };

  # Theming with stylix
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    fonts = {
      monospace = pkgs.dejavu_fonts;
      sansSerif = pkgs.dejavu_fonts;
      serif = pkgs.dejavu_fonts;
    };
  };

  # Niri configuration
  programs.niri = {
    enable = true;
    settings = import ../config/niri.nix { inherit pkgs lib; };
  };

  # Ensure necessary packages are installed
  home.packages = with pkgs; [
    swaybg # For setting the wallpaper
    pipewire
  ];
}
