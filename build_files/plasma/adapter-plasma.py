#!/usr/bin/env python3
"""Adapte la coque de Plasma (plasma-desktop) à Windows 11 (D-052).

Les volets de la barre (Démarrer, horloge, zone de notification…) sont
ouverts par desktoppackage/contents/applet/CompactApplet.qml de
plasma-desktop, installé tel quel dans l'image (fichier QML, non compilé).
Avec une barre collée, Plasma colle ces volets à la barre, sans bord ni
coins de ce côté. Windows 11 les fait flotter à 12 px de la barre, avec
leurs quatre coins arrondis (mon choix du 2026-10-22). Avec une marge,
libplasma garde les quatre bords du volet et la même distance aux bords de
l'écran (PopupPlasmaWindowPrivate::updateBorders et
TransientPlacementHint, src/plasmaquick de libplasma 6.7).

Le texte remplacé est vérifié : si une nouvelle version de Plasma l'a
changé, la construction échoue au lieu de laisser les volets collés.

Usage : adapter-plasma.py <dossier de la coque org.kde.plasma.desktop>
"""

import pathlib
import sys

RACINE = pathlib.Path(sys.argv[1])


def remplacer(fichier: str, avant: str, apres: str) -> None:
    chemin = RACINE / fichier
    texte = chemin.read_text(encoding="utf-8")
    nombre = texte.count(avant)
    if nombre != 1:
        sys.exit(f"adapter-plasma.py : {chemin} contient {nombre} fois, au lieu d'une, le texte :\n{avant}")
    chemin.write_text(texte.replace(avant, apres), encoding="utf-8")


remplacer(
    "contents/applet/CompactApplet.qml",
    "        margin: (Plasmoid.containmentDisplayHints & PlasmaCore.Types.ContainmentPrefersFloatingApplets) ? Kirigami.Units.largeSpacing : 0\n",
    "        // Ankh : le volet flotte à 12 px de la barre et des bords de l'écran,\n"
    "        // avec ses quatre coins arrondis, comme Windows 11 (D-052) ; les\n"
    "        // widgets du bureau gardent leur volet sans marge\n"
    "        margin: Plasmoid.location === PlasmaCore.Types.Floating ? 0 : 12\n",
)
