# ❄️ Low-Spec Hyprland Rice

<div align="center">
  <img src="https://img.shields.io/github/stars/okyashgajjar/low-sepecs-hyprland-dotfiles?style=for-the-badge&logo=github&color=b4befe" />
  <img src="https://img.shields.io/github/last-commit/okyashgajjar/low-sepecs-hyprland-dotfiles?style=for-the-badge&logo=git&color=a6e3a1" />
  <img src="https://img.shields.io/github/repo-size/okyashgajjar/low-sepecs-hyprland-dotfiles?style=for-the-badge&logo=files&color=f9e2af" />
</div>

<p align="center">
  <b>A lightweight, aesthetically pleasing Hyprland configuration optimized for low-end hardware.</b><br>
  <i>Built for speed without sacrificing the modern "blurred" look.</i>
</p>

<div align="center">
  <a href="#-gallery">Gallery</a> •
  <a href="#-highlights">Highlights</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-keybinds">Keybinds</a> •
  <a href="#-credits">Credits</a>
</div>

---

## ✨ Sparkles Dotfiles Showcase ✨

![Hyprland Rice Preview](https://raw.githubusercontent.com/okyashgajjar/low-sepecs-hyprland-dotfiles/main/homepage.jpg)

### 🖼️ Gallery
| Noro Theme (Modular Pill) | Material Theme |
| :---: | :---: |
| ![Noro](https://raw.githubusercontent.com/okyashgajjar/low-sepecs-hyprland-dotfiles/main/minimal-dark.jpg) | ![Material](https://raw.githubusercontent.com/okyashgajjar/low-sepecs-hyprland-dotfiles/main/mount-fuji.jpg) |

| Retro Styled | Bottom Dock |
| :---: | :---: |
| ![Retro](https://raw.githubusercontent.com/okyashgajjar/low-sepecs-hyprland-dotfiles/main/retro-styled.jpg) | ![Bottom](https://raw.githubusercontent.com/okyashgajjar/low-sepecs-hyprland-dotfiles/main/bottom.jpg) |

---

## 🚀 Highlights

- 🎨 **Dynamic Theming**: Powered by **Matugen**, colors automatically shift to match your wallpaper.
- 🛠️ **Theme-Aware Selectors**: Specialized menus to change wallpapers and Waybar styles specifically for your active theme.
- 📦 **Organized Wallpapers**: A curated set of wallpapers bundled and organized by theme for instant use.
- 󰘵 **Modular Pill Aesthetic**: Introducing the **Noro** theme — a clean, modular pill-styled Waybar with dynamic user branding.
- ⚡ **Low-Spec Optimized**: Animations and blur are tuned to maintain high performance even on Celeron N4020 systems.

---

> [!IMPORTANT]
> **Read this First**
> This install script is intended for Arch Linux or EndeavourOS. It will automatically install dependencies using `yay`. Please ensure you have an AUR helper installed before running.

> [!CAUTION]
> **Backup your system**
> Always backup your existing `.config` files before running the installer. The script will attempt to create a backup in `~/.config_backup_...`, but manual safety is recommended.

---

## 📦 Installation

### 🆕 Prerequisites
- **AUR Helper**: `yay` or `paru` (required for Matugen and Ghostty).
- **Base System**: Arch Linux / EndeavourOS (Minimal install recommended).

### 🚀 Quick Install
```bash
git clone --depth=1 https://github.com/okyashgajjar/low-sepecs-hyprland-dotfiles.git
cd low-sepecs-hyprland-dotfiles
chmod +x install.sh
./install.sh
```

---

## ⌨️ Keybinds

| Keybind | Action |
| :--- | :--- |
| `SUPER + Return` | Open Terminal (Kitty) |
| `SUPER + Space` | App Launcher (Rofi) |
| `SUPER + B` | Launch Browser (Brave) |
| `SUPER + Q` | Kill Active Window |
| `SUPER + T` | **Theme / Wallpaper Selector** |
| `SUPER + SHIFT + C` | Reload Hyprland |
| `SUPER + SHIFT + 1-9`| Move Window to Workspace |

---

## 🛠️ Core Stack
| Component | Program |
| :--- | :--- |
| **Window Manager** | `Hyprland` |
| **Status Bar** | `Waybar` |
| **Wallpaper** | `Awww` / `SWWW` |
| **Launcher** | `Rofi-Wayland` |
| **Theming** | `Matugen` |
| **Terminal** | `Kitty` / `Ghostty` |

---

## 📒 Final Notes
*   **Performance**: If you are on high-end hardware, feel free to re-enable blur and animations in `hyprland.conf`.
*   **Fonts**: The default font is **JetBrainsMono Nerd Font**.

### 🤝 Credits & Support
- **Hyprland**: For the amazing tiling manager.
- **Support**: A Star 🌟 on my Github repo would be appreciated!

---
*Developed with love for low-spec warriors.*
