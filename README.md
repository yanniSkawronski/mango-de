# Environnement de bureau MangoWM

Environnement de bureau custom centré sur le compositeur Wayland
[MangoWM](https://github.com/mangowm/mango) (dwm-like, basé sur wlroots/scenefx).

## Contenu

```
mango-desktop/
├── README.md            ← ce fichier
├── install.sh           ← installe MangoWM (Arch/Fedora : paquet ; Debian/Ubuntu : build source)
├── deploy.sh            ← copie la config dans ~/.config/mango (avec backup)
├── validate.sh          ← valide la config SANS lancer le compositeur
├── headless-smoke.sh    ← démarre mango en headless (VM/CI, local uniquement)
├── tools/
│   ├── check-config.sh  ← vérification statique des clés/actions de la config
│   ├── valid-keys.txt   ← clés valides (extraites du parser mango)
│   └── valid-actions.txt← actions de bind valides (extraites du dispatcher)
└── mango/               ← la configuration, à déployer dans ~/.config/mango
    ├── config.conf      ← point d'entrée : env, variables, source=..., exec_once
    ├── theme.conf       ← couleurs, gaps, bordures, flou, ombres, animations
    ├── layout.conf      ← layouts par tag, scroller, dwindle, monocle, overview
    ├── input.conf       ← clavier (fr), souris, trackpad
    ├── rules.conf       ← window_rule / layer_rule
    ├── bind.conf        ← raccourcis clavier, souris, molette, gestes
    └── autostart.sh     ← barre waybar, fond d'écran, presse-papiers, polkit...
```

## Valider la configuration (la commande clé)

MangoWM permet de vérifier un fichier de config **sans démarrer le compositeur** :

```bash
mango -c ~/.config/mango/config.conf -p
```

- `-c <fichier>` : utiliser ce fichier de config
- `-p` : parser la config puis quitter — code de sortie `0` = valide, `1` = invalide

Cette commande fonctionne **sans écran ni session Wayland** (le parsing a lieu
avant toute initialisation wlroots ; voir `src/main.c`, `check_config`).

Script équivalent fourni :

```bash
./validate.sh                 # valide ~/.config/mango/config.conf
./validate.sh mango/config.conf
MANGO_BIN=/usr/local/bin/mango ./validate.sh
```

Vérification statique sans le binaire (clés inconnues, actions invalides,
`source=` cassés) :

```bash
tools/check-config.sh
```

## Installation et déploiement

```bash
./install.sh     # installe mango (+ deps)
./deploy.sh      # déploie la config dans ~/.config/mango
./validate.sh    # valide la config déployée
# puis, dans un TTY : mango   (ou via votre display manager)
```

Test headless local (VM/CI, aucune exposition réseau) :

```bash
./headless-smoke.sh
```

## Personnalisation

- Raccourcis : `mango/bind.conf` (noms de touches = sortie de `xev`/`wev`,
  modificateurs `SUPER`, `CTRL`, `ALT`, `SHIFT`, combinables avec `+`)
- Variables réutilisables : `var=term,foot` puis `bind=SUPER,Return,spawn,$term`
- Fichiers inclus : `source=./autre.conf` (chemin relatif au fichier inclus)
- Rechargement à chaud : `SUPER+r` (`reload_config`)
