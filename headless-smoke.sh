#!/usr/bin/env bash
# Test de fumée LOCAL de mango en mode headless (wlroots), sur la machine
# elle-même uniquement : aucun serveur exposé, socket Wayland local.
# Utile en VM/CI pour valider que le compositeur démarre avec la config.
set -euo pipefail

CONFIG="${1:-$HOME/.config/mango/config.conf}"
RUNTIME="${XDG_RUNTIME_DIR:-/tmp/mango-xdg}"
mkdir -p "$RUNTIME"
chmod 700 "$RUNTIME"

echo "==> Démarrage headless de mango (Ctrl+C pour arrêter)"
WLR_BACKENDS=headless \
WLR_LIBINPUT_NO_DEVICES=1 \
XDG_RUNTIME_DIR="$RUNTIME" \
mango -c "$CONFIG"
