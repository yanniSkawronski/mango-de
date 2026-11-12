#!/usr/bin/env bash
# Installe MangoWM (+ dépendances) selon la distribution.
# Debian/Ubuntu : compilation depuis les sources (wlroots 0.20, scenefx 0.5).
# Arch / Fedora : paquets officiels (AUR / dépôt Terra).
set -euo pipefail

SUDO="sudo"
command -v sudo >/dev/null 2>&1 || SUDO=""

build_from_source() {
    echo "==> Compilation depuis les sources (wlroots -> scenefx -> mango)"
    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update
        $SUDO apt-get install -y \
            build-essential git meson ninja-build pkg-config ca-certificates \
            libwayland-dev wayland-protocols libxkbcommon-dev \
            libinput-dev libudev-dev libevdev-dev libdrm-dev libgbm-dev \
            libegl-dev libgles-dev libpixman-1-dev \
            libdisplay-info-dev libliftoff-dev hwdata \
            libpcre2-dev libseat-dev libcjson-dev \
            libpango1.0-dev libcairo2-dev \
            libxcb1-dev libxcb-icccm4-dev libxcb-randr0-dev libxcb-xinput-dev \
            xwayland seatd
    fi

    export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/local/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    PREFIX=/usr/local
    WORK="${MANGO_BUILD_DIR:-$HOME/.build/mango}"
    mkdir -p "$WORK"
    cd "$WORK"

    clone_build_install() {
        local repo="$1" name="$2"
        if [[ ! -d "$name" ]]; then
            git clone --depth 1 "$repo" "$name"
        fi
        cd "$name"
        meson setup build --prefix="$PREFIX" --buildtype=release -Dwerror=false
        ninja -C build
        $SUDO ninja -C build install
        cd ..
    }

    clone_build_install https://gitlab.freedesktop.org/wlroots/wlroots.git wlroots
    clone_build_install https://github.com/DreamMaoMao/scenefx.git scenefx
    clone_build_install https://github.com/mangowm/mango.git mango
    $SUDO ldconfig
    echo "==> mango installé dans $PREFIX/bin/mango"
}

if command -v pacman >/dev/null 2>&1; then
    echo "==> Arch Linux détecté"
    if command -v yay >/dev/null 2>&1; then AUR=yay
    elif command -v paru >/dev/null 2>&1; then AUR=paru
    else AUR=""; fi
    if $SUDO pacman -S --needed --noconfirm mangowm 2>/dev/null; then
        :
    elif [[ -n "$AUR" ]]; then
        $AUR -S --needed --noconfirm mangowm-git
    else
        echo "Installez un helper AUR (yay/paru) ou lancez en Debian-like." >&2
        exit 1
    fi
elif command -v dnf >/dev/null 2>&1; then
    echo "==> Fedora détecté (dépôt Terra)"
    $SUDO dnf install -y --nogpgcheck \
        --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" terra-release
    $SUDO dnf install -y mangowm
else
    build_from_source
fi

echo "==> Vérification : mango -v"
mango -v
