#!/bin/bash
set -euo pipefail

echo "🔧 Installing packages..."
while read -r pkg; do
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "$pkg already installed"
    else
        echo "Installing $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg"
    fi
done < packages.txt

echo "📁 Setting up PipeWire config..."
mkdir -p "$HOME/.config/pipewire/pipewire.conf.d"
cp -r config/pipewire/pipewire.conf.d/* "$HOME/.config/pipewire/pipewire.conf.d/"

echo "🔁 Restarting PipeWire services..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber
systemctl --user restart pipewire pipewire-pulse wireplumber

echo "🔧 Configuring UFW firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow ssh

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

sudo ufw enable

sudo ufw status verbose

echo "✅ Installation complete!"
