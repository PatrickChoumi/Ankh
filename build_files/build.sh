#!/usr/bin/bash
# Personnalisations d'Ankh appliquées pendant la construction de l'image.
# Chaque ajout cite la décision qui le justifie (DECISIONS.md) et a son test
# dans « just test ».
set -euo pipefail

# D-010 : pas de redémarrage automatique. Ce timer peut télécharger, appliquer
# une mise à jour puis redémarrer la machine ; la documentation Fedora bootc
# recommande de le masquer pendant la construction de l'image pour l'éviter.
# https://docs.fedoraproject.org/en-US/bootc/auto-updates/
systemctl mask bootc-fetch-apply-updates.timer

# D-028 : les mises à jour du système s'affichent dans Discover. kinoite-main
# retire ce module ; KDE a corrigé depuis le problème qui avait motivé ce
# retrait (https://github.com/ublue-os/main/pull/282). Le module ne redémarre
# jamais seul : il signale qu'un redémarrage est nécessaire (D-010).
dnf5 -y install plasma-discover-rpm-ostree
