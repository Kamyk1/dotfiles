#!/bin/bash
set -euo pipefail

START_DIR="$(pwd)"

cp config/wallpapers/mywallpaper1.mp4 ~/Wideo/

echo "Installing packages..."
while read -r pkg; do
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "$pkg already installed"
    else
        echo "Installing $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg"
    fi
done < packages.txt

clear

echo "Setting up PipeWire config..."
mkdir -p "$HOME/.config/pipewire/pipewire.conf.d"
cp -r config/pipewire/pipewire.conf.d/* "$HOME/.config/pipewire/pipewire.conf.d/"

echo "Restarting PipeWire services..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber
systemctl --user restart pipewire pipewire-pulse wireplumber

clear

echo "Configuring UFW firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow ssh

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

sudo ufw enable

sudo ufw status verbose

clear

echo "Setting up BetterDiscord"
curl -fsSL https://bun.com/install | bash

cd ~/
git clone --single-branch -b main https://github.com/BetterDiscord/BetterDiscord.git
cd ~/BetterDiscord
bun install
bun run build
bun inject

echo "Setting up Kde Themes"

sh "$START_DIR/install-kde.sh"

echo "Setting up Alacritty"

git clone https://github.com/rose-pine/alacritty.git
cp ./alacritty/dist/* ~/.config/alacritty
printf '\n[general]\nimport = ["rose-pine.toml"]\n' > ~/.config/alacritty/alacritty.toml

echo "Installation complete!"
rm -rf $HOME/Pulpit/dotfiles

sleep 5
