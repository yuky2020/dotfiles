#!/usr/bin/env bash
# Install these dotfiles: packages (via paru) + symlinks into ~/.config and ~/.local/bin.
# Existing configs are moved to ~/.config/dotfiles-backup-<timestamp> before linking.
#
# Usage: ./install.sh [--no-packages] [--no-sunshine]

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
CONFIGS=(hypr noctalia alacritty ghostty)
SUNSHINE_SCRIPTS=(sunshine-start.sh sunshine-connect.sh sunshine-disconnect.sh sunshine-after-sleep.sh)

INSTALL_PACKAGES=1
INSTALL_SUNSHINE=1
for arg in "$@"; do
    case "$arg" in
        --no-packages) INSTALL_PACKAGES=0 ;;
        --no-sunshine) INSTALL_SUNSHINE=0 ;;
        -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

read_pkgs() { grep -vE '^\s*(#|$)' "$1"; }

# --- 1. packages ------------------------------------------------------------
if [ $INSTALL_PACKAGES = 1 ]; then
    if ! command -v paru >/dev/null 2>&1; then
        echo "paru not found. Install it first: https://github.com/Morganamilo/paru" >&2
        exit 1
    fi
    pkgs=($(read_pkgs "$DOTFILES/packages.txt"))
    [ $INSTALL_SUNSHINE = 1 ] && pkgs+=($(read_pkgs "$DOTFILES/packages-sunshine.txt"))
    paru -S --needed "${pkgs[@]}"
fi

# --- 2. symlinks ------------------------------------------------------------
link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "ok      $dst"
        return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP"
        mv "$dst" "$BACKUP/"
        echo "backup  $dst -> $BACKUP/"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "link    $dst -> $src"
}

for c in "${CONFIGS[@]}"; do
    link "$DOTFILES/config/$c" "$HOME/.config/$c"
done

if [ $INSTALL_SUNSHINE = 1 ]; then
    for s in "${SUNSHINE_SCRIPTS[@]}"; do
        link "$DOTFILES/bin/$s" "$HOME/.local/bin/$s"
    done
else
    # autostart.lua launches sunshine-start.sh; drop that line when Sunshine is skipped.
    sed -i '/sunshine-start.sh/d' "$DOTFILES/config/hypr/autostart.lua"
fi

# --- 3. per-user paths ------------------------------------------------------
# Noctalia stores the wallpaper directory as an absolute path.
sed -i "s|\"/home/[^/\"]*/Pictures/Wallpapers\"|\"$HOME/Pictures/Wallpapers\"|" \
    "$DOTFILES/config/noctalia/settings.json"
mkdir -p "$HOME/Pictures/Wallpapers"

echo
echo "Done. Next steps:"
echo "  - Edit ~/.config/hypr/monitors.lua for your outputs (hyprctl monitors)."
echo "  - Put wallpapers in ~/Pictures/Wallpapers."
[ $INSTALL_SUNSHINE = 1 ] && echo "  - Sunshine: see examples/sunshine/ and the README."
echo "  - Log out and pick Hyprland in your display manager."
