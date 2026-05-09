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

# List of dependencies
DEPS=(
    "hyprland" "waybar" "swww" "rofi-wayland" "dunst" "kitty" 
    "matugen-bin" "ttf-jetbrains-mono-nerd" "brightnessctl" "wireplumber"
    "zsh" "fastfetch" "curl" "git" "rsync"
)

# Install dependencies if using yay
if command -v yay &> /dev/null; then
    echo "📦 Installing dependencies..."
    yay -S --needed "${DEPS[@]}"
else
    echo "⚠️ Please ensure you have the following installed: ${DEPS[*]}"
fi

# Backup existing configs
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

CONFIGS=("hypr" "waybar" "kitty" "rofi" "dunst" "matugen")

echo "📂 Setting up configurations..."
for config in "${CONFIGS[@]}"; do
    if [ -d "$HOME/.config/$config" ]; then
        echo "   - Backing up ~/.config/$config"
        mv "$HOME/.config/$config" "$BACKUP_DIR/"
    fi
    cp -r ".config/$config" "$HOME/.config/"
done

# Install wallpapers (organized by theme)
echo "🖼️ Installing organized wallpapers..."
mkdir -p "$HOME/wallpapers"
cp -r wallpapers/* "$HOME/wallpapers/"

# Set permissions for scripts
echo "🔑 Setting executable permissions for scripts..."
chmod +x "$HOME/.config/hypr/scripts/"*
chmod +x "$HOME/.config/waybar/scripts/"*

# Initial Theme Setup (Noro by default)
echo "🎨 Initializing Noro theme..."
ln -sf "$HOME/.config/hypr/themes/noro/theme.conf" "$HOME/.config/hypr/theme.conf"
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

echo "✅ Done! Please restart your session or reload Hyprland (SUPER + SHIFT + C)."
echo "Your old configs are saved in: $BACKUP_DIR"
