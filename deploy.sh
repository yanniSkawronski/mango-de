#!/usr/bin/env bash
# Déploie la configuration MangoWM dans ~/.config/mango
# (l'ancien dossier est sauvegardé avec un suffixe .bak-<date>)
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/mango" && pwd)"
DST="$HOME/.config/mango"

if [[ -d "$DST" ]]; then
    BAK="$DST.bak-$(date +%Y%m%d%H%M%S)"
    mv "$DST" "$BAK"
    echo "Ancienne config sauvegardée dans : $BAK"
fi

mkdir -p "$DST"
cp "$SRC"/*.conf "$SRC"/autostart.sh "$DST/"
chmod +x "$DST/autostart.sh"

echo "Configuration déployée dans : $DST"
echo "Validez-la avec : mango -c $DST/config.conf -p"
