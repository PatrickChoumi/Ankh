#!/usr/bin/env python3
"""Adapte le style QtQuick de KDE (org.kde.desktop) aux mesures de Windows 11.

D-052, lot 3. Les applications QML de KDE (Réglages, Discover…) dessinent
leurs contrôles avec qqc2-desktop-style : le style des contrôles d'Ankh
(build_files/style) dessine les boutons, cases et champs, mais quelques
contrôles sont écrits en QML, et leurs tailles aussi. Ce script les modifie
dans l'image, à leur place :
- l'interrupteur (private/SwitchIndicator.qml) est remplacé par celui
  d'Ankh : 40×20, comme le ToggleSwitch de Windows 11 ;
- une case, un bouton radio ou un interrupteur avec son texte gardent la
  hauteur de leur indicateur (32 pour une case), même quand la ligne de
  texte dépasse un peu la hauteur de la police ;
- un élément de liste (ItemDelegate) fait au moins 40 px de haut
  (ListViewItemMinHeight) ;
- les infobulles sont écrites en petite police (12 px,
  ToolTipContentThemeFontSize) ;
- un bouton mis en avant (highlighted) est rempli de la couleur d'accent,
  comme le bouton par défaut, et ses icônes prennent la couleur prévue sur
  l'accent.

Ces fichiers QML sont aussi compilés dans le greffon du module : la ligne
« prefer » de leur qmldir fait charger cette copie compilée. Elle est
retirée, pour que les fichiers modifiés soient lus.

Chaque modification vérifie le texte qu'elle remplace : si une nouvelle
version de qqc2-desktop-style l'a changé, la construction échoue au lieu
de laisser un contrôle à moitié adapté.

Usage : adapter.py <dossier org/kde/desktop> <SwitchIndicator.qml d'Ankh>
"""

import pathlib
import sys

RACINE = pathlib.Path(sys.argv[1])
INTERRUPTEUR = pathlib.Path(sys.argv[2])


def remplacer(fichier: str, avant: str, apres: str) -> None:
    chemin = RACINE / fichier
    texte = chemin.read_text(encoding="utf-8")
    nombre = texte.count(avant)
    if nombre != 1:
        sys.exit(f"adapter.py : {chemin} contient {nombre} fois, au lieu d'une, le texte :\n{avant}")
    chemin.write_text(texte.replace(avant, apres), encoding="utf-8")


# Fichiers lus sur le disque, et non dans le greffon compilé
remplacer("qmldir", "prefer :/qt/qml/org/kde/desktop/\n", "")
remplacer("private/qmldir", "prefer :/qt/qml/org/kde/desktop/private/\n", "")

# Interrupteur : celui d'Ankh garde l'interface de l'original
original = (RACINE / "private/SwitchIndicator.qml").read_text(encoding="utf-8")
for attendu in ("property T.AbstractButton control", "property alias handle: handle"):
    if attendu not in original:
        sys.exit(f"adapter.py : l'interrupteur de KDE n'a plus « {attendu} » : revoir {INTERRUPTEUR}")
(RACINE / "private/SwitchIndicator.qml").write_text(INTERRUPTEUR.read_text(encoding="utf-8"), encoding="utf-8")

# Case, bouton radio, interrupteur : hauteur de l'indicateur, sans la
# fraction de pixel que la ligne de texte ajoute
for fichier, controle in (("CheckBox.qml", "controlRoot"), ("RadioButton.qml", "controlRoot"), ("Switch.qml", "control")):
    remplacer(
        fichier,
        "        bottomPadding: topPadding\n",
        "        // Ankh : sur une ligne, le contrôle garde la hauteur de son\n"
        "        // indicateur (D-052, lot 3)\n"
        f"        bottomPadding: lineCount > 1 ? topPadding : Math.max(0, {controle}.implicitIndicatorHeight - topPadding - contentHeight)\n",
    )

# Élément de liste : 40 px au moins
remplacer(
    "ItemDelegate.qml",
    "    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,\n"
    "                             implicitContentHeight + topPadding + bottomPadding,\n"
    "                             implicitIndicatorHeight + topPadding + bottomPadding)\n",
    "    // Ankh : 40 px au moins, comme ListViewItemMinHeight de Windows 11\n"
    "    // (D-052, lot 3)\n"
    "    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,\n"
    "                             implicitContentHeight + topPadding + bottomPadding,\n"
    "                             implicitIndicatorHeight + topPadding + bottomPadding,\n"
    "                             40)\n",
)

# Infobulle : petite police
remplacer(
    "ToolTip.qml",
    "    Kirigami.Theme.inherit: false\n",
    "    Kirigami.Theme.inherit: false\n"
    "    // Ankh : 12 px, comme ToolTipContentThemeFontSize de Windows 11\n"
    "    // (D-052, lot 3)\n"
    "    font: Kirigami.Theme.smallFont\n",
)

# Bouton mis en avant : rempli d'accent, comme le bouton par défaut
remplacer(
    "Button.qml",
    "    Kirigami.Theme.inherit: false\n",
    "    Kirigami.Theme.inherit: false\n"
    "\n"
    "    // Ankh : bouton par défaut ou mis en avant, rempli de la couleur\n"
    "    // d'accent par le style (AccentButtonStyle de Windows 11, D-052, lot 3)\n"
    "    readonly property bool __ankhAccent: (Accessible.defaultButton || highlighted) && !flat && enabled\n",
)
remplacer(
    "Button.qml",
    "        hasFocus: controlRoot.activeFocus || controlRoot.highlighted\n"
    "        activeControl: controlRoot.Accessible.defaultButton ? \"default\" : \"\"\n",
    "        hasFocus: controlRoot.activeFocus\n"
    "        activeControl: controlRoot.__ankhAccent ? \"default\" : \"\"\n",
)
remplacer(
    "Button.qml",
    "            \"iconColor\": Qt.colorEqual(controlRoot.icon.color, \"transparent\") ? Kirigami.Theme.textColor : controlRoot.icon.color,\n",
    "            \"iconColor\": Qt.colorEqual(controlRoot.icon.color, \"transparent\")\n"
    "                ? (controlRoot.__ankhAccent ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor)\n"
    "                : controlRoot.icon.color,\n",
)
