#!/bin/bash
set -e

echo "Installing KDE Plasma themes and setting defaults: Rose Pine + Sweet KDE + WhiteSur"

COLOR_DIR="$HOME/.local/share/color-schemes"
mkdir -p "$COLOR_DIR"
TMP="$(mktemp -d)"

echo "Downloading Rose Pine KDE color schemes..."
git clone https://github.com/ashbork/kde "$TMP/rosepine"
find "$TMP/rosepine" -type f -name "*.colors" -exec cp {} "$COLOR_DIR/" \;

PLASMA_THEME_DIR="$HOME/.local/share/plasma/desktoptheme"
LOOKANDFEEL_DIR="$HOME/.local/share/plasma/look-and-feel"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/WhiteSur"

mkdir -p "$PLASMA_THEME_DIR" "$LOOKANDFEEL_DIR" "$WALLPAPER_DIR"

echo "Downloading WhiteSur KDE..."
git clone https://github.com/vinceliuice/WhiteSur-kde "$TMP/whitesur"

cp -r "$TMP/whitesur/plasma/desktoptheme/"* "$PLASMA_THEME_DIR/"
cp -r "$TMP/whitesur/plasma/look-and-feel/"* "$LOOKANDFEEL_DIR/" 2>/dev/null || true
cp -r "$TMP/whitesur/wallpaper/"* "$WALLPAPER_DIR/" 2>/dev/null || true

rm -rf "$TMP"

echo "Refreshing Plasma..."
kquitapp6 plasmashell && kstart5 plasmashell &

echo "Setting default theme to WhiteSur and colors to Rose Pine..."
lookandfeeltool -a "WhiteSur" || true
kwriteconfig6 --file kdeglobals --group General --key ColorScheme "Rose Pine"

echo "Done! Themes are installed and defaulted."
echo "You may need to restart your session for all settings to fully apply."
