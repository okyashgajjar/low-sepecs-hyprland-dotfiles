# ❄️ Low-Spec Hyprland Rice

A lightweight, aesthetically pleasing Hyprland configuration optimized for low-end hardware (e.g., Intel Celeron N4020). Built for speed without sacrificing the modern "blurred" look through clever color palettes and efficient module design.

## 🚀 Highlights
- **Engineered for Efficiency**: Animations and blur are disabled by default to maintain <10% CPU usage.
- **Dynamic Theming**: Powered by **Matugen**, colors automatically shift to match your wallpaper.
- **Minimalist Aesthetic**: Clean "Pill" styled Waybar and minimalist Rofi menus.
- **Hardware Verified**: Tested on 2-core processors with 4GB RAM.

## 🛠️ Hardware Requirements
- **Recommended**: Intel Celeron / Pentium / Core i3 (2+ cores)
- **Memory**: 4GB+ RAM
- **GPU**: Integrated Intel UHD / AMD Radeon
- **OS**: Arch Linux or EndeavourOS (recommended)

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
*(Add your screenshots here)*

---
*Developed with love for low-spec warriors.*
