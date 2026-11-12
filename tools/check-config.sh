#!/usr/bin/env bash
# Vérification STATIQUE d'un fichier de config mango (sans binaire mango) :
#  - chaque clé de premier niveau doit exister dans les tables du parser
#    (tools/valid-keys.txt, extrait de src/config/option_defs.c)
#  - chaque action de bind/mousebind/... doit exister dans le dispatcher
#    (tools/valid-actions.txt, extrait de src/config/binding_parse.c)
#  - chaque source= doit pointer vers un fichier existant
# Usage : tools/check-config.sh [fichier.conf ...]   (défaut: mango/*.conf)
set -u
shopt -s extglob
cd "$(dirname "${BASH_SOURCE[0]}")/.."

KEYS=tools/valid-keys.txt
ACTIONS=tools/valid-actions.txt
FILES=("$@")
[[ ${#FILES[@]} -eq 0 ]] && FILES=(mango/*.conf)

errors=0

is_valid_key() {
    grep -qxF "$1" "$KEYS" && return 0
    # clés de binding avec flags : bind, binds, bindl, mousebind, axisbind...
    [[ "$1" =~ ^(bind|mousebind|axisbind|switchbind|gesturebind)[slrpc]*$ ]] && return 0
    return 1
}

is_valid_action() {
    grep -qxF "$1" "$ACTIONS"
}

for f in "${FILES[@]}"; do
    [[ -f "$f" ]] || { echo "FICHIER INTROUVABLE: $f" >&2; errors=$((errors+1)); continue; }
    dir="$(dirname "$f")"
    lineno=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        lineno=$((lineno+1))
        line="${line%%#*}"                       # retire les commentaires
        line="${line##+([[:space:]])}"; line="${line%%+([[:space:]])}"
        [[ -z "$line" ]] && continue
        key="${line%%=*}"
        key="${key##+([[:space:]])}"; key="${key%%+([[:space:]])}"
        if ! is_valid_key "$key"; then
            echo "$f:$lineno: clé inconnue: $key" >&2
            errors=$((errors+1))
            continue
        fi
        case "$key" in
            source|source_optional)
                target="${line#*=}"
                target="${target/#\~/$HOME}"
                [[ "$target" == /* ]] || target="$dir/$target"
                if [[ ! -f "$target" && "$key" == "source" ]]; then
                    echo "$f:$lineno: source introuvable: ${line#*=}" >&2
                    errors=$((errors+1))
                fi
                ;;
            bind|mousebind|axisbind|switchbind|bind[slrpc]*)
                action="$(echo "${line#*=}" | awk -F, '{print $3}')"
                ;;
            gesturebind*)
                action="$(echo "${line#*=}" | awk -F, '{print $4}')"
                ;;
        esac
        if [[ "${key}" =~ ^(bind|mousebind|axisbind|switchbind|gesturebind) ]]; then
            action="${action##+([[:space:]])}"; action="${action%%+([[:space:]])}"
            if [[ -n "$action" ]] && ! is_valid_action "$action"; then
                echo "$f:$lineno: action inconnue: $action" >&2
                errors=$((errors+1))
            fi
        fi
    done < "$f"
done

if [[ $errors -eq 0 ]]; then
    echo "OK: ${#FILES[@]} fichier(s) vérifié(s), aucune erreur."
    exit 0
else
    echo "$errors erreur(s) détectée(s)." >&2
    exit 1
fi
