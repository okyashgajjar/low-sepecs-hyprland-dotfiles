#!/usr/bin/env bash

# ──────────────────────────────────────────────────────────────────────────────
#   Low-Spec Hyprland Dotfiles Installer
#   Optimized for Intel Celeron / 4GB RAM Systems
# ──────────────────────────────────────────────────────────────────────────────

set -e

echo "🚀 Starting installation..."

# Check for Arch/EndeavourOS
if [ ! -f /etc/arch-release ]; then
    echo "❌ Error: This script is intended for Arch-based distributions (Arch/EndeavourOS)."
    exit 1
fi

# List of dependencies (awww is the wallpaper daemon used here; swww/hyprpaper also work)
DEPS=(
    "hyprland" "waybar" "rofi-wayland" "dunst" "kitty"
    "matugen-bin" "ttf-jetbrains-mono-nerd" "brightnessctl" "wireplumber"
    "zsh" "fastfetch" "curl" "git" "rsync"
)
# awww/swww/hyprpaper are alternatives for wallpaper — ensure one is present
WALLPAPER_DEPS=("awww" "swww" "hyprpaper")

# Install dependencies if using an AUR helper (yay/paru)
AUR_HELPER=""
if command -v yay &> /dev/null; then AUR_HELPER="yay"
elif command -v paru &> /dev/null; then AUR_HELPER="paru"
fi

if [ -n "$AUR_HELPER" ]; then
    echo "📦 Installing dependencies via $AUR_HELPER..."
    $AUR_HELPER -S --needed "${DEPS[@]}"
    # Try to ensure a wallpaper daemon is present (non-fatal if AUR package missing)
    for wp in "${WALLPAPER_DEPS[@]}"; do
        if ! pacman -Qi "$wp" &>/dev/null && ! command -v "$wp" &>/dev/null; then
            echo "   → trying $wp..."
            $AUR_HELPER -S --needed "$wp" 2>/dev/null || true
            command -v "$wp" &>/dev/null && break
            command -v awww &>/dev/null && break
            command -v swww &>/dev/null && break
        else
            break
        fi
    done
else
    echo "⚠️ No AUR helper (yay/paru) found — please ensure manually: ${DEPS[*]} + one of: ${WALLPAPER_DEPS[*]}"
fi

# Backup existing configs
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

CONFIGS=("hypr" "waybar" "kitty" "rofi" "dunst" "matugen" "nvim" "fastfetch")

echo "📂 Setting up configurations..."
for config in "${CONFIGS[@]}"; do
    if [ ! -d ".config/$config" ]; then
        # skip optional configs not present in repo (e.g. gtk configs are intentionally user-local)
        continue
    fi
    if [ -d "$HOME/.config/$config" ]; then
        echo "   - Backing up ~/.config/$config"
        mv "$HOME/.config/$config" "$BACKUP_DIR/"
    fi
    # -a preserves symlinks (theme.conf/theme.lua → themes/noro/...) and permissions
    cp -a ".config/$config" "$HOME/.config/"
done

# Install wallpapers (organized by theme)
echo "🖼️ Installing organized wallpapers..."
mkdir -p "$HOME/wallpapers"
# -a preserves structure; copy only if wallpapers exists in repo
if [ -d "wallpapers" ]; then
    cp -a wallpapers/. "$HOME/wallpapers/"
else
    echo "   ⚠️ wallpapers/ not found in repo — skipping"
fi

# Set permissions for scripts
echo "🔑 Setting executable permissions for scripts..."
chmod +x "$HOME/.config/hypr/scripts/"*
chmod +x "$HOME/.config/waybar/scripts/"*

# Initial Theme Setup (Noro by default) — hyprlang .conf + Lua .lua (0.55+)
echo "🎨 Initializing Noro theme..."
ln -sf "$HOME/.config/hypr/themes/noro/theme.conf" "$HOME/.config/hypr/theme.conf"
if [ -f "$HOME/.config/hypr/themes/noro/theme.lua" ]; then
    ln -sf "$HOME/.config/hypr/themes/noro/theme.lua" "$HOME/.config/hypr/theme.lua"
fi
ln -sf "$HOME/.config/waybar/themes/noro/config.jsonc" "$HOME/.config/waybar/config.jsonc"
ln -sf "$HOME/.config/waybar/themes/noro/style.css" "$HOME/.config/waybar/style.css"
ln -sf "$HOME/.config/rofi/themes/noro/launcher.rasi" "$HOME/.config/rofi/active-launcher.rasi"
ln -sf "$HOME/.config/rofi/themes/noro/scripts.rasi" "$HOME/.config/rofi/active-scripts.rasi"
echo "Noro" > "$HOME/.config/hypr/.active-theme"

# Install Oh My Zsh and copy .zshrc
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "🔌 Installing zsh-plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ -f ".zshrc" ]; then
    echo "📝 Installing .zshrc config..."
    [ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$BACKUP_DIR/"
    cp ".zshrc" "$HOME/.zshrc"
fi

# Post-install sanity check: which Hyprland config will be used?
if command -v hyprctl &>/dev/null; then
    HYPR_VER=$(hyprctl version 2>/dev/null | head -n1 || hyprland --version 2>/dev/null | head -n1 || echo "unknown")
    echo "   Hyprland: $HYPR_VER"
    if [ -f "$HOME/.config/hypr/hyprland.lua" ] && [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
        echo "   → Both hyprland.lua (0.55+ Lua) and hyprland.conf (legacy) present. Hyprland 0.55+ prefers hyprland.lua."
        echo "     • Hyprland ≥0.55 → hyprland.lua + theme.lua/colors.lua (Matugen writes both .conf/.lua)"
        echo "     • Hyprland <0.55 → hyprland.conf + theme.conf/colors.conf (fallback)"
    fi
    # Validate lua syntax when lua is available
    if command -v luac &>/dev/null && [ -f "$HOME/.config/hypr/hyprland.lua" ]; then
        luac -p "$HOME/.config/hypr/hyprland.lua" && echo "   ✓ hyprland.lua syntax OK" || echo "   ✗ hyprland.lua has syntax errors — check hyprctl configerrors"
    fi
fi
if [ -f "$HOME/.config/hypr/theme.lua" ]; then
    echo "   ✓ theme.lua → $(readlink "$HOME/.config/hypr/theme.lua" 2>/dev/null || echo "present")"
fi
if [ -f "$HOME/.config/hypr/theme.conf" ]; then
    echo "   ✓ theme.conf → $(readlink "$HOME/.config/hypr/theme.conf" 2>/dev/null || echo "present")"
fi

echo "✅ Done! Please restart your session or reload Hyprland (SUPER + SHIFT + C / hyprctl reload)."
echo "   Your old configs are saved in: $BACKUP_DIR"
echo "   Tips:"
echo "     • Change theme: SUPER+T (theme) / SUPER+SHIFT+T (global) / SUPER+W (waybar)"
echo "     • Change wallpaper: SUPER+T → Change Wallpaper (theme-aware, Matugen regenerates colors.lua+colors.conf)"
echo "     • If Hyprland fails to start, fallback is hyprland.conf — remove hyprland.lua to force legacy"
