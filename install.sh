#!/bin/bash
set -euo pipefail

# Zapamiętujemy gdzie jest główny folder dotfiles, żeby cp zawsze działało
DOTFILES_DIR=$(pwd)

sudo pacman -Syu pipewire-jack

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
cp -r "$DOTFILES_DIR/config/pipewire/pipewire.conf.d/"* "$HOME/.config/pipewire/pipewire.conf.d/"

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
sudo ufw --force enable # --force, żeby nie pytał o potwierdzenie w skrypcie

clear

echo "Setting up BetterDiscord"
# Upewnij się, że masz zainstalowany 'betterdiscordctl' i 'discord' w packages.txt
betterdiscordctl install
mkdir -p "$HOME/.config/BetterDiscord/themes"
cp "$DOTFILES_DIR/config/Betterdiscord/style.css" "$HOME/.config/BetterDiscord/themes/"

echo "Setting up Spicetify with CachyBrown theme..."
# Instalacja spicetify-cli (bezpiecznie używa binarek)
curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | sh

# Poprawione literówki i ścieżki
mkdir -p "$HOME/.config/spicetify/Themes/CachyBrown"
cp -r "$DOTFILES_DIR/config/spotify/CachyBrown/"* "$HOME/.config/spicetify/Themes/CachyBrown/"

# Backup i Apply (poprawione 'spicetfiy')
spicetify backup apply || spicetify apply 
spicetify config current_theme CachyBrown
spicetify apply

echo "Setting up iNiR"
cd "$HOME"
git clone https://github.com/snowarch/inir.git || true # || true w razie gdyby folder już istniał
cd inir
./setup install

echo "Installation complete!"
sleep 5
