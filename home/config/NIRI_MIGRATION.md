# Niri Migration Guide

This document explains the migration from Sway to Niri and the key differences you need to know.

## What is Niri?

Niri is a scrollable-tiling Wayland compositor that provides a different approach to window management compared to traditional tiling window managers like Sway. Instead of splitting windows into smaller and smaller rectangles, Niri arranges windows in columns that you can scroll through horizontally.

## Key Differences from Sway

### Tiling Philosophy
- **Sway**: Traditional binary space partitioning (windows split into smaller rectangles)
- **Niri**: Scrollable columns (windows arranged in columns, scroll horizontally between columns)

### Window Management
- **Focus**: Use `Mod+Left/Right` or `Mod+H/L` to move between columns
- **Vertical Focus**: Use `Mod+Up/Down` or `Mod+J/K` to move between windows in a column
- **Moving Windows**: `Mod+Shift+` combinations move windows between columns or within columns
- **Resizing**: `Mod+R` cycles through preset column widths (no manual resizing like Sway)

### Features Not Directly Equivalent

1. **Scratchpad**: Niri doesn't have a direct equivalent to Sway's scratchpad. The config includes a placeholder for handling `dropdown` windows.

2. **Floating Windows**: Niri doesn't have traditional floating windows. Instead, it uses column presets that can make windows appear "floating-like".

3. **Manual Window Splits**: You can't manually split windows horizontally/vertically like in Sway. Niri handles the layout automatically.

4. **Push-to-Talk**: The push-to-talk feature needs adjustment since Niri's key handling might be different for key release events.

## Configuration Structure

Niri uses KDL (KubeML Document Language) for configuration instead of Nix expressions. The config file is located at `~/.config/niri/config.kdl`.

## Migration Checklist

### ✅ Migrated Successfully
- [x] Basic key bindings (terminal, launcher, etc.)
- [x] Media keys (volume, brightness, playback)
- [x] Screenshots with Flameshot
- [x] Workspace switching (1-10)
- [x] Window focus and movement
- [x] Lock screen functionality
- [x] Startup applications (background, dark mode)
- [x] Input configuration (touchpad)
- [x] Output configuration (scaling)
- [x] Application-specific window rules

### ⚠️ Needs Adjustment
- [ ] **Scratchpad functionality**: No direct equivalent in Niri
- [ ] **Push-to-talk key release**: Niri might handle key releases differently
- [x] **Window CWD detection**: Now uses `niri msg focused-window` to get current working directory
- [ ] **Resize mode**: Niri uses preset column widths instead of manual resizing
- [ ] **Status bar**: May need adjustment to work with Niri

### 🔄 Different Approach
- [ ] **Window splitting**: Use column-based workflow instead of manual splits
- [ ] **Floating windows**: Use column presets instead of traditional floating

## How to Enable

1. **Install Niri**: Make sure to use stable nixpkgs for the niri package:
   ```nix
   # In your home.nix or wherever you import this module:
   { pkgs, ... }:
   let
     pkgs-unstable = import <stable nixpkgs> {};
   in
   {
     home.packages = [
       pkgs.niri
       # ... other packages
     ];
     
     imports = [
       ./config/niri.nix
     ];
   }
   ```

2. **Switch from Display Manager**: If you're currently using a display manager to start Sway, you'll need to:
   - Configure your display manager to offer Niri as an option, or
   - Start Niri manually from a TTY, or
   - Use the systemd service (uncommented in the niri.nix file)

3. **Test the Configuration**: Start with a fresh session to test the key bindings and functionality.

## Learning the New Workflow

### Basic Operations
1. **Open Terminal**: `Mod+Return` (same as Sway)
2. **Focus Columns**: `Mod+Left/Right` or `Mod+H/L`
3. **Focus Windows in Column**: `Mod+Up/Down` or `Mod+J/K`
4. **Move Windows**: `Mod+Shift+[direction]`
5. **Change Column Width**: `Mod+R`
6. **Fullscreen**: `Mod+F`

### Workspace Management
- Workspaces work similarly to Sway
- `Mod+[1-9,0]` to switch to workspace
- `Mod+Shift+[1-9,0]` to move window to workspace
- `Mod+Alt+Left/Right` to cycle through workspaces

## Troubleshooting

### Common Issues
1. **Applications don't start**: Check that Wayland environment variables are set correctly
2. **Scaling issues**: Adjust the `scale` value in the output configuration
3. **Key bindings don't work**: Verify the KDL syntax in the config file

### Debug Commands
```bash
# Check niri is running
niri --help

# View niri logs (if using systemd)
journalctl --user -u niri

# Test configuration syntax
niri validate-config ~/.config/niri/config.kdl
```

## Further Customization

The Niri configuration is highly customizable. Check the [Niri documentation](https://github.com/YaLTeR/niri) for:
- Advanced layout options
- Animation settings
- Additional window rules
- Theming options

Remember that Niri is a different paradigm from traditional tiling window managers. Give yourself time to adapt to the scrollable column workflow!


## Desktop 2025 Edition

The Desktop 2025 Edition is a complete modernization of the desktop setup that goes beyond just migrating from Sway to Niri. It includes:

### Component Migrations

| Component | Old (Sway Era) | New (Desktop 2025) | Status |
|-----------|----------------|--------------------|---------|
| **Compositor** | Sway | Niri | ✅ Complete |
| **Status Bar** | i3status-rust | Waybar | ✅ Complete |
| **Terminal** | Alacritty | Wezterm | ✅ Complete |
| **Launcher** | Rofi | Fuzzel | ✅ Complete |
| **Theming** | Manual GTK | Stylix + GTK | 🚧 Partial |
| **Notifications** | - | Dunst | ✅ Complete |

### How to Use Desktop 2025 Edition

#### Option 1: Full Desktop 2025 Edition
```nix
# In your home.nix
{
  imports = [
    ./config/desktop-2025.nix
  ];
  
  # Your other configuration...
}
```

#### Option 2: Individual Components
```nix
# Pick and choose components
{
  imports = [
    ./config/niri.nix      # Niri compositor
    ./config/waybar.nix    # Waybar status bar  
    ./config/wezterm.nix   # Wezterm terminal
    ./config/fuzzel.nix    # Fuzzel launcher
    # ./config/stylix.nix  # Optional theming
  ];
}
```

### Key Differences in Desktop 2025

#### Waybar vs i3status-rust
- **More configurable**: Native support for modules, styling, and animations
- **Better integration**: Direct support for Niri workspaces and window titles
- **Modern styling**: CSS-based theming with hover effects and transitions
- **Interactive elements**: Click handlers for volume, brightness controls

#### Wezterm vs Alacritty
- **GPU acceleration**: Better performance for complex terminal usage
- **Multiplexing**: Built-in tabs and panes (no need for tmux for basic usage)
- **Ligatures**: Full support for programming fonts with ligatures
- **Lua configuration**: More flexible configuration language
- **Image protocol**: Support for displaying images in terminal

#### Fuzzel vs Rofi
- **Native Wayland**: Better integration with Wayland compositors
- **Simpler**: Focused launcher without the complexity of Rofi's many modes
- **Fast**: Optimized for speed and low resource usage
- **Consistent theming**: Better integration with system color schemes

### Migration Path

1. **Start with Niri**: Use the existing `niri.nix` module (already updated for Desktop 2025)
2. **Add Waybar**: Enable the waybar module for a modern status bar
3. **Switch Terminal**: Try Wezterm - it should be a drop-in replacement for most use cases
4. **Try Fuzzel**: Fuzzel may need adjustment if you use complex Rofi configurations
5. **Optional Theming**: Add stylix when ready for unified theming

### Compatibility Notes

- **rofi-screenlayout**: Still uses Rofi for now (not yet ported to Fuzzel)
- **Custom scripts**: Any scripts using `rofi -dmenu` need updating to `fuzzel --dmenu`
- **Keybindings**: Most keybindings remain the same, but some Fuzzel shortcuts differ
- **Themes**: Manual theme configuration still works alongside automatic theming

### Performance Benefits

- **Lower memory usage**: Niri + Fuzzel use less RAM than Sway + Rofi
- **Better GPU utilization**: Wezterm and Waybar leverage GPU acceleration
- **Faster startup**: Fuzzel launches much faster than Rofi
- **Smoother animations**: Native Wayland protocols provide better frame timing

### Future Roadmap

- **Complete Stylix integration**: Unified theming across all components
- **Custom Fuzzel modes**: Port remaining Rofi functionality to Fuzzel
- **Niri-specific features**: Leverage unique Niri features like column presets
- **Performance optimization**: Fine-tune all components for the Framework laptop
