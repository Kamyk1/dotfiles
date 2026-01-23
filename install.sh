#!/bin/bash
set -euo pipefail
echo "🔧 Installing packages..."
while read -r pkg; do
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "$pkg already installed"
    else
        echo "Installing $pkg..."
        if pacman -Ss "$pkg" | grep -q community; then
            sudo pacman -S --needed --noconfirm "$pkg"
        else
            yay -S --needed --noconfirm "$pkg"
        fi
    fi
done < packages.txt
echo "📁 Setting up PipeWire config..."
mkdir -p "$HOME/.config/pipewire/pipewire.conf.d"
mkdir -p "$HOME/.config/pipewire/wireplumber"
cp -r config/pipewire/pipewire.conf.d/* "$HOME/.config/pipewire/pipewire.conf.d/"
cp -r config/pipewire/wireplumber/* "$HOME/.config/pipewire/wireplumber/"
echo "🔁 Restarting PipeWire services..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber
systemctl --user restart pipewire pipewire-pulse wireplumber

echo "✅ Installation complete!"
