#!/usr/bin/env bash
# Valide un fichier de configuration MangoWM SANS lancer le compositeur.
#
#   mango -c <fichier> -p
#
# -c <fichier> : utiliser ce fichier de config
# -p           : parser la config puis quitter (0 = valide, 1 = invalide)
# Aucun écran ni session Wayland n'est requis pour cette commande.
#
# Usage : ./validate.sh [fichier.conf]
set -u

CONFIG="${1:-$HOME/.config/mango/config.conf}"
BIN="${MANGO_BIN:-mango}"

if ! command -v "$BIN" >/dev/null 2>&1; then
    echo "ERREUR: binaire '$BIN' introuvable. Installez MangoWM ou définissez MANGO_BIN=/chemin/vers/mango" >&2
    exit 127
fi
if [[ ! -f "$CONFIG" ]]; then
    echo "ERREUR: fichier de config introuvable: $CONFIG" >&2
    exit 2
fi

echo "==> Validation de : $CONFIG"
if "$BIN" -c "$CONFIG" -p; then
    echo "==> OK : la configuration est valide."
    exit 0
else
    echo "==> INVALIDE : des erreurs ont été détectées (voir messages ci-dessus)." >&2
    exit 1
fi
