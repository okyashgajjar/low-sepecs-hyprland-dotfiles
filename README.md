# ❄️ Low-Spec Hyprland Rice

A lightweight, aesthetically pleasing Hyprland configuration optimized for low-end hardware (e.g., Intel Celeron N4020). Built for speed without sacrificing the modern "blurred" look through clever color palettes and efficient module design.

## 🚀 Highlights
- **Engineered for Efficiency**: Animations and blur are disabled by default to maintain <10% CPU usage.
- **Dynamic Theming**: Powered by **Matugen**, colors automatically shift to match your wallpaper.
- **Minimalist Aesthetic**: Clean "Pill" styled Waybar and minimalist Rofi menus.
- **Hardware Verified**: Tested on 2-core processors with 4GB RAM.

## 🛠️ System Requirements
- **OS**: Arch Linux or EndeavourOS (required for the package names in `install.sh`).
- **Hardware**: Optimized for low-spec (Celeron N4020+), but works perfectly on high-end systems.
- **AUR Helper**: `yay` or `paru` (required for Matugen and Ghostty).

## 📦 Core Dependencies
These will be installed automatically by `install.sh`, but are listed here for manual setup:

| Component | Package Name | Purpose |
| :--- | :--- | :--- |
| **Window Manager** | `hyprland` | Core desktop environment |
| **Status Bar** | `waybar` | Top panel with Matugen integration |
| **Wallpaper** | `awww` | High-performance wallpaper daemon |
| **App Menu** | `rofi-wayland` | Application launcher and power menu |
| **Notifications** | `dunst` | Minimalist notification daemon |
| **Theming** | `matugen-bin` | **Critical**: Generates colors from wallpapers |
| **Terminal** | `kitty` or `ghostty` | GPU-accelerated terminals |
| **Brightness** | `brightnessctl` | Backlight control |
| **Audio** | `wireplumber` | Audio control via `wpctl` |

## 󰛖 Fonts Required
For the icons to display correctly, you **must** have a Nerd Font installed:
- `ttf-jetbrains-mono-nerd` (Default in this rice)
- `ttf-font-awesome` (Optional backup)

## 📦 Programs
List of programs and tools I use.

| Component | Program |
| :--- | :--- |
| **Windows Manager** 🪟 | `hyprland` |
| **Terminal** 🖥️ | `kitty` |
| **Shell** 🐚 | `zsh` / theme |
| **Fetch** 🖼️ | `catnip` / icon |
| **File Manager** 📁 | `ranger` |
| **Editor** 📝 | `neovim` / `nvchad` |
| **Browser** 🌐 | `firefox` / startpage / startpage wal |
| **Bar** 📊 | `waybar` |
| **Launcher** 🚀 | `rofi` |
| **Color Theme** 🎨 | `pywal` |
| **Lockscreen** 🔒 | `hyprlock` |
| **Login Menu** 🚪 | `sddm` |
| **Music Player** 🎵 | `ncspot` |
| **Visualiser** 📊 | `cava` |
| **Lyrics** 🎤 | `sptlrx` |
| **Pomodoro** 🍅 | `tomato-c` |
| **Others** 🌱 | `cbonsai`, `colorscripts`, `asciiquarium` |

## 📦 Installation

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/low-spec-hyprland.git
cd low-spec-hyprland
```

### 2. Run the install script
```bash
chmod +x install.sh
./install.sh
```

### 3. Manual Installation (Other Hardware)
If you are on a high-spec system and want to enable blur/animations:
1. Copy the `.config/` directories to your `~/.config/`.
2. Edit `~/.config/hypr/hyprland.conf`:
   - Set `animations { enabled = true }`
   - Set `decoration { blur { enabled = true } }`

## ⌨️ Keybinds
- `SUPER + Return`: Terminal (Kitty)
- `SUPER + Space`: App Menu (Rofi)
- `SUPER + B`: Browser (Brave)
- `SUPER + Q`: Kill Active Window
- `SUPER + T`: Select Wallpaper & Update Theme
- `SUPER + SHIFT + 1-9`: Move window to workspace

## 🎨 Screenshots
![Hyprland Rice Preview](https://raw.githubusercontent.com/okyashgajjar/low-sepecs-hyprland-dotfiles/main/homepage.jpg)
![System Monitor (htop)](https://raw.githubusercontent.com/okyashgajjar/low-sepecs-hyprland-dotfiles/main/htop.jpg)
---
*Developed with love for low-spec warriors.*
