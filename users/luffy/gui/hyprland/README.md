# Hyprland Configuration

This directory contains the Hyprland window manager configuration for the luffy host.

## Configuration Structure

- **`default.nix`** - Home-manager integration with packages and services
- **`hyprland.conf`** - Traditional Hyprland configuration file with all settings
- **System level** - Minimal enablement in `hosts/luffy/modules/hyprland.nix`

## Key Bindings

### Window Management
- `Super+Q` - Close active window
- `Super+V` - Toggle floating mode
- `Super+F` - Toggle fullscreen
- `Super+P` - Toggle pseudotiling
- `Super+J` - Toggle split direction
- `Super+M` - Exit Hyprland

### Applications
- `Super+Return` - Open terminal (kitty)
- `Super+E` - Open file manager (nautilus)
- `Super+R` - Application launcher (rofi)

### Navigation (Vim-style)
- `Super+h/j/k/l` - Focus left/down/up/right
- `Super+Shift+h/j/k/l` - Move window left/down/up/right

### Workspaces
- `Super+1-0` - Switch to workspace 1-10
- `Super+Shift+1-0` - Move window to workspace 1-10
- `Super+S` - Toggle scratchpad workspace
- `Super+Shift+S` - Move window to scratchpad

### Screenshots
- `Print` - Screenshot selection (with annotation)
- `Super+Print` - Screenshot full screen (with annotation)

### Audio Controls
- `XF86AudioRaiseVolume` - Increase volume by 5%
- `XF86AudioLowerVolume` - Decrease volume by 5%
- `XF86AudioMute` - Toggle mute

### Mouse
- `Super+Left Click` - Move window
- `Super+Right Click` - Resize window

## Visual Features

- **Rounded corners** - 10px radius
- **Smooth animations** - Custom bezier curves
- **Window transparency** - Semi-transparent terminal
- **Drop shadows and blur** - Modern visual effects
- **Catppuccin-inspired colors** - Blue/teal accent borders

## Included Applications

- **kitty** - GPU-accelerated terminal with transparency
- **rofi-wayland** - Application launcher
- **waybar** - Status bar
- **mako** - Notification daemon
- **grim/slurp/swappy** - Screenshot utilities
- **nautilus** - File manager
- **wl-clipboard** - Clipboard utilities

## Window Rules

- Audio control (pavucontrol) - Floats by default
- File manager (nautilus) - Floats by default
- Terminal (kitty) - 80% opacity
- Firefox - Opens on workspace 2
- Code editor - Opens on workspace 3

## Startup Applications

- **waybar** - Status bar automatically starts
- **mako** - Notification daemon automatically starts

## Customization

To modify settings, edit `hyprland.conf` directly. Changes take effect after reloading Hyprland (`Super+Shift+R` or restart session).

For package changes or service configuration, modify `default.nix` and rebuild with `just sw`.