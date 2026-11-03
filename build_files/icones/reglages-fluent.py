#!/usr/bin/python3
"""D-052, lot 10o : dans les icônes d'applications de Fluent (scalable/apps),
seules restent celles des réglages (preferences-*).

Le lot 10g avait retiré tout scalable/apps de Fluent pour que chaque
application garde son icône, comme dans Windows 11. Mais les pages de la
Configuration du système y prennent aussi leurs icônes (preferences-desktop-
mouse, preferences-desktop-display…). Sans elles, KDE raccourcit le nom
(preferences-desktop-mouse, puis preferences-desktop) et trouve l'icône
d'action générique de Fluent avant celle de Breeze (KIconLoader cherche le
nom et ses raccourcis dans un thème avant de passer au thème hérité) : sur les
captures en VM, Souris, Son, Écran et Accessibilité avaient tous la même
icône de curseurs. Les icônes des réglages font partie du système : elles
restent ; les icônes d'applications partent.

Un lien gardé dont la cible part devient une copie de la cible.

Usage : reglages-fluent.py DOSSIER (scalable/apps, fichiers réels)
"""

import os
import shutil
import sys
from pathlib import Path


def echec(message):
    print(f"Icônes de réglages de Fluent : {message}", file=sys.stderr)
    sys.exit(1)


def garde(nom):
    return nom.startswith("preferences-")


def main():
    if len(sys.argv) != 2:
        echec("usage : reglages-fluent.py DOSSIER")
    dossier = Path(sys.argv[1])
    if not dossier.is_dir() or dossier.is_symlink():
        echec(f"{dossier} : pas un dossier réel")
    entrees = sorted(dossier.iterdir())
    # Cibles lues avant tout changement ; un lien gardé dont un maillon de la
    # chaîne part (preferences-system-users -> yast-users -> system-users ->
    # preferences-desktop-user) devient une copie de sa cible finale
    a_recopier = {}
    for entree in entrees:
        if garde(entree.name) and entree.is_symlink():
            maillon = entree
            while maillon.is_symlink():
                maillon = (maillon.parent / os.readlink(maillon))
                if maillon.parent.resolve() == dossier.resolve() and not garde(maillon.name):
                    a_recopier[entree] = entree.resolve()
                    break
    copies = 0
    for entree, cible in a_recopier.items():
        if not cible.exists():
            echec(f"{entree} : cible {cible} absente")
        entree.unlink()
        shutil.copy2(cible, entree)
        copies += 1
    retirees = 0
    for entree in entrees:
        if not garde(entree.name):
            entree.unlink()
            retirees += 1
    restes = sorted(dossier.iterdir())
    if not restes:
        echec("aucune icône de réglages : Fluent a changé")
    for entree in restes:
        if not garde(entree.name):
            echec(f"{entree} : icône d'application restée")
        if not os.path.exists(entree):
            echec(f"{entree} : lien sans cible")
    print(f"Icônes de réglages de Fluent : {len(restes)} gardées ({copies} liens recopiés), {retirees} icônes d'applications retirées")


if __name__ == "__main__":
    main()
