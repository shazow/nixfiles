# Wezterm terminal configuration
# Replaces Alacritty in Desktop 2025 Edition
{
  pkgs,
  lib,
  ...
}:
{
  programs.wezterm = {
    enable = true;
    
    extraConfig = ''
      local config = {}
      
      -- Color scheme
      config.color_scheme = "Solarized Dark - Patched"
      
      -- Font configuration
      config.font = wezterm.font_with_fallback({
        "DejaVu Sans Mono",
        "FontAwesome",
      })
      config.font_size = 10.0
      
      -- Window appearance
      config.window_decorations = "RESIZE"
      config.window_background_opacity = 1.0
      config.text_background_opacity = 1.0
      
      -- Tab bar
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.use_fancy_tab_bar = false
      config.tab_bar_at_bottom = false
      
      -- Scrollback
      config.scrollback_lines = 10000
      
      -- Key bindings (similar to default terminal behavior)
      config.keys = {
        -- Copy/paste
        {
          key = 'c',
          mods = 'CTRL|SHIFT',
          action = wezterm.action.CopyTo('Clipboard'),
        },
        {
          key = 'v',
          mods = 'CTRL|SHIFT',
          action = wezterm.action.PasteFrom('Clipboard'),
        },
        
        -- New tab/window
        {
          key = 't',
          mods = 'CTRL|SHIFT',
          action = wezterm.action.SpawnTab('CurrentPaneDomain'),
        },
        {
          key = 'n',
          mods = 'CTRL|SHIFT',
          action = wezterm.action.SpawnWindow,
        },
        
        -- Close tab
        {
          key = 'w',
          mods = 'CTRL|SHIFT',
          action = wezterm.action.CloseCurrentTab({ confirm = true }),
        },
        
        -- Navigate tabs
        {
          key = 'Tab',
          mods = 'CTRL',
          action = wezterm.action.ActivateTabRelative(1),
        },
        {
          key = 'Tab',
          mods = 'CTRL|SHIFT',
          action = wezterm.action.ActivateTabRelative(-1),
        },
        
        -- Font size adjustment
        {
          key = '=',
          mods = 'CTRL',
          action = wezterm.action.IncreaseFontSize,
        },
        {
          key = '-',
          mods = 'CTRL',
          action = wezterm.action.DecreaseFontSize,
        },
        {
          key = '0',
          mods = 'CTRL',
          action = wezterm.action.ResetFontSize,
        },
      }
      
      -- Mouse bindings
      config.mouse_bindings = {
        -- Ctrl-click to open hyperlinks
        {
          event = { Up = { streak = 1, button = 'Left' } },
          mods = 'CTRL',
          action = wezterm.action.OpenLinkAtMouseCursor,
        },
        
        -- Right click to paste
        {
          event = { Up = { streak = 1, button = 'Right' } },
          mods = 'NONE',
          action = wezterm.action.PasteFrom('Clipboard'),
        },
      }
      
      -- Bell
      config.audible_bell = "Disabled"
      config.visual_bell = {
        fade_in_function = "EaseIn",
        fade_in_duration_ms = 150,
        fade_out_function = "EaseOut",
        fade_out_duration_ms = 150,
      }
      
      -- Performance
      config.max_fps = 60
      config.animation_fps = 1
      config.cursor_blink_rate = 800
      config.cursor_blink_ease_in = 'Constant'
      config.cursor_blink_ease_out = 'Constant'
      
      -- Wayland specific settings
      config.enable_wayland = true
      
      return config
    '';
  };
}
