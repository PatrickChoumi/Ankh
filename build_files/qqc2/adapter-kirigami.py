#!/usr/bin/env python3
"""Adapte les éléments de liste de Kirigami à la sélection de Windows 11.

D-052, lot 8 (mon choix du 2026-10-24, « Applis Windows 11 ») : dans les
listes de Windows 11, l'élément choisi garde son texte et ses icônes
(ListViewItemForegroundSelected : TextFillColorPrimary), sur un fond discret
avec un trait d'accent, que le style d'Ankh dessine (build_files/style).
Les applications QML de KDE (Réglages, Discover…) montrent leurs éléments de
liste avec les délégués de Kirigami (org.kde.kirigami.delegates), qui
mettent le texte et les icônes de l'élément choisi dans la couleur posée
sur l'accent (highlightedTextColor) : illisible sur un fond discret clair.
Ce script les modifie dans l'image, à leur place :
- TitleSubtitle.qml : titre et sous-titre gardent leurs couleurs ;
- IconTitleSubtitle.qml : l'icône garde la sienne.

Ces fichiers QML sont aussi compilés dans le greffon du module : la ligne
« prefer » de leur qmldir fait charger cette copie compilée. Elle est
retirée, pour que les fichiers modifiés soient lus (comme pour
qqc2-desktop-style, build_files/qqc2/adapter.py).

Chaque modification vérifie le texte qu'elle remplace : si une nouvelle
version de Kirigami l'a changé, la construction échoue.

Usage : adapter-kirigami.py <dossier org/kde/kirigami/delegates>
"""

import pathlib
import sys

RACINE = pathlib.Path(sys.argv[1])


def remplacer(fichier: str, avant: str, apres: str) -> None:
    chemin = RACINE / fichier
    texte = chemin.read_text(encoding="utf-8")
    nombre = texte.count(avant)
    if nombre != 1:
        sys.exit(f"adapter-kirigami.py : {chemin} contient {nombre} fois, au lieu d'une, le texte :\n{avant}")
    chemin.write_text(texte.replace(avant, apres), encoding="utf-8")


# Fichiers lus sur le disque, et non dans le greffon compilé
remplacer("qmldir", "prefer :/qt/qml/org/kde/kirigami/delegates/\n", "")

remplacer(
    "TitleSubtitle.qml",
    "    property color color: selected ? Platform.Theme.highlightedTextColor : Platform.Theme.textColor\n",
    "    // Ankh : texte inchangé sur l'élément choisi (D-052, lot 8)\n"
    "    property color color: Platform.Theme.textColor\n",
)
remplacer(
    "TitleSubtitle.qml",
    "    property color subtitleColor: selected\n"
    "        ? Platform.Theme.highlightedTextColor\n"
    "        : Platform.ColorUtils.linearInterpolation(color, Platform.Theme.backgroundColor, 0.25)\n",
    "    // Ankh : sous-titre inchangé sur l'élément choisi (D-052, lot 8)\n"
    "    property color subtitleColor: Platform.ColorUtils.linearInterpolation(color, Platform.Theme.backgroundColor, 0.25)\n",
)
remplacer(
    "IconTitleSubtitle.qml",
    "        selected: root.selected\n"
    "        color: root.icon.color\n",
    "        // Ankh : icône inchangée sur l'élément choisi (D-052, lot 8)\n"
    "        selected: false\n"
    "        color: root.icon.color\n",
)
