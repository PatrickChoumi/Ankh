#!/usr/bin/bash
# Personnalisations d'Ankh appliquées pendant la construction de l'image.
# Phase 1 : volontairement minimal. L'image doit d'abord prouver que la
# construction, les tests, la publication et la signature fonctionnent.
set -euo pipefail

# D-010 : pas de redémarrage automatique. Ce timer peut télécharger, appliquer
# une mise à jour puis redémarrer la machine ; la documentation Fedora bootc
# recommande de le masquer pendant la construction de l'image pour l'éviter.
# https://docs.fedoraproject.org/en-US/bootc/auto-updates/
systemctl mask bootc-fetch-apply-updates.timer

# TEST VOLONTAIRE (phase 1) : un nom de paquet erroné doit faire échouer la CI
# et bloquer la fusion. Ce bloc sera retiré dans le commit suivant.
dnf5 -y install ankh-paquet-inexistant-test-pr-cassee
