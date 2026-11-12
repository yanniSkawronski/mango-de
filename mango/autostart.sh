#!/usr/bin/env bash
# Autostart MangoWM — lancé une fois au démarrage via exec_once.
# Chaque outil est lancé uniquement s'il est installé.
set +e

run() {
    if command -v "$1" >/dev/null 2>&1; then
        "$@" &
    fi
}

# Propager les variables d'environnement à la session D-Bus
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
fi

# Barre de statut
run waybar -c "$HOME/.config/mango/waybar/config.jsonc" -s "$HOME/.config/mango/waybar/style.css"

# Fond d'écran (placer une image à ~/.config/mango/wallpaper.jpg)
run swaybg -i "$HOME/.config/mango/wallpaper.jpg"

# Presse-papiers persistant + historique
run wl-clip-persist --clipboard regular --reconnect-tries 0
if command -v wl-paste >/dev/null 2>&1 && command -v cliphist >/dev/null 2>&1; then
    wl-paste --type text --watch cliphist store &
fi

# Filtre lumière bleue (nuit)
run wlsunset -T 3501 -t 3500

# Agent d'authentification polkit
if [[ -x /usr/lib/xfce-polkit/xfce-polkit ]]; then
    /usr/lib/xfce-polkit/xfce-polkit &
fi

# DPI XWayland
if command -v xrdb >/dev/null 2>&1; then
    echo "Xft.dpi: 120" | xrdb -merge
fi
