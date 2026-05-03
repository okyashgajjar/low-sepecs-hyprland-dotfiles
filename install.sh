#!/usr/bin/env bash

# ──────────────────────────────────────────────────────────────────────────────
#   Low-Spec Hyprland Dotfiles Installer
#   Optimized for Intel Celeron / 4GB RAM Systems
# ──────────────────────────────────────────────────────────────────────────────

set -e

echo "Starting installation..."

# Check for Arch/EndeavourOS
if [ ! -f /etc/arch-release ]; then
    echo "Error: This script is intended for Arch-based distributions (Arch/EndeavourOS)."
    exit 1
fi

# List of dependencies
DEPS=(
    "hyprland" "waybar" "swww" "rofi-wayland" "dunst" "kitty" 
    "matugen-bin" "ttf-jetbrains-mono-nerd" "brightnessctl" "wpctl"
    "zsh" "fastfetch" "curl" "git"
)

# Install dependencies if using yay
if command -v yay &> /dev/null; then
    echo "Installing dependencies..."
    yay -S --needed "${DEPS[@]}"
else
    echo "Please ensure you have the following installed: ${DEPS[*]}"
fi

# Backup existing configs
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

CONFIGS=("hypr" "waybar" "kitty" "rofi" "dunst" "matugen" "gtk-3.0" "gtk-4.0")

for config in "${CONFIGS[@]}"; do
    if [ -d "$HOME/.config/$config" ]; then
        echo "Backing up ~/.config/$config to $BACKUP_DIR"
        mv "$HOME/.config/$config" "$BACKUP_DIR/"
    fi
    echo "Installing new $config config..."
    cp -r ".config/$config" "$HOME/.config/"
done

# Install wallpapers
echo "Installing default wallpapers..."
mkdir -p "$HOME/wallpapers"
cp -rn wallpapers/* "$HOME/wallpapers/" 2>/dev/null || true

# Install Oh My Zsh and copy .zshrc
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

echo "Installing .zshrc config..."
if [ -f "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$BACKUP_DIR/"
fi
cp ".zshrc" "$HOME/.zshrc"

# Install GTK Themes
echo "Installing GTK themes..."
mkdir -p "$HOME/.themes"
cp -rn .themes/* "$HOME/.themes/" 2>/dev/null || true

echo "Done! Please restart your session or reload Hyprland (SUPER + SHIFT + C)."
echo "Your old configs are saved in: $BACKUP_DIR"
