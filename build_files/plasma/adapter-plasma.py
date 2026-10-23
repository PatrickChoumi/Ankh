#!/usr/bin/env python3
"""Adapte la coque de Plasma (plasma-desktop) à Windows 11 (D-052).

Deux parties : les volets de la barre (lot 4) et l'écran de verrouillage
(lot 7c).

Les volets de la barre (Démarrer, horloge, zone de notification…) sont
ouverts par desktoppackage/contents/applet/CompactApplet.qml de
plasma-desktop, installé tel quel dans l'image (fichier QML, non compilé).
Avec une barre collée, Plasma colle ces volets à la barre, sans bord ni
coins de ce côté. Windows 11 les fait flotter à 12 px de la barre, avec
leurs quatre coins arrondis (mon choix du 2026-10-22). Avec une marge,
libplasma garde les quatre bords du volet et la même distance aux bords de
l'écran (PopupPlasmaWindowPrivate::updateBorders et
TransientPlacementHint, src/plasmaquick de libplasma 6.7).

L'écran de verrouillage (contents/lockscreen, lu par kscreenlocker_greet)
prend le dessin de l'écran de connexion d'Ankh (D-043), comme je l'ai
choisi le 2026-10-23 (« Comme la connexion d'Ankh ») : l'horloge d'Ankh
(HorlogeAnkh.qml, posé avec les fichiers de l'image) en haut, et un champ de
mot de passe arrondi, au contour d'accent quand il a le focus. Seul le
dessin change : l'authentification (Connections sur « authenticator »),
l'effacement du mot de passe, le blocage après un échec et les actions
restent ceux de KDE.

Le texte remplacé est vérifié : si une nouvelle version de Plasma l'a
changé, la construction échoue au lieu de laisser les volets collés ou un
écran de verrouillage à moitié adapté.

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

# Écran de verrouillage : l'horloge d'Ankh, en haut de l'écran comme à la
# connexion (9 % de la hauteur), au lieu de celle de KDE entre le haut et le
# compte
remplacer(
    "contents/lockscreen/LockScreenUi.qml",
    "        Clock {\n"
    "            id: clock\n"
    "            property Item shadow: clockShadow\n"
    "            visible: y > 0 && config.alwaysShowClock\n"
    "            anchors.horizontalCenter: parent.horizontalCenter\n"
    "            y: (mainBlock.userList.y + mainStack.y)/2 - height/2\n"
    "            Layout.alignment: Qt.AlignBaseline\n"
    "        }\n",
    "        // Ankh (D-052, lot 7c) : l'horloge de l'écran de connexion d'Ankh\n"
    "        HorlogeAnkh {\n"
    "            id: clock\n"
    "            shadow: clockShadow\n"
    "            visible: config.alwaysShowClock\n"
    "            anchors.horizontalCenter: parent.horizontalCenter\n"
    "            y: Math.round(parent.height * 0.09)\n"
    "        }\n",
)

# Écran de verrouillage : le champ de mot de passe arrondi de la connexion
# d'Ankh, translucide, au contour d'accent (focusColor, D-054) quand il a le
# focus
remplacer(
    "contents/lockscreen/MainBlock.qml",
    "        PlasmaExtras.PasswordField {\n"
    "            id: passwordBox\n"
    "            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1\n",
    "        PlasmaExtras.PasswordField {\n"
    "            id: passwordBox\n"
    "            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1\n"
    "            // Ankh (D-052, lot 7c) : le champ arrondi de l'écran de connexion\n"
    "            // d'Ankh, dessiné sous le texte. Le fond de KDE reste, caché : les\n"
    "            // marges du texte et des boutons du champ en dépendent (le\n"
    "            // remplacer fait une boucle de liaison sur la hauteur)\n"
    "            background.visible: false\n"
    "            placeholderTextColor: Qt.rgba(1, 1, 1, 0.70)\n"
    "            Rectangle {\n"
    "                z: -1\n"
    "                anchors.fill: parent\n"
    "                anchors.leftMargin: -8\n"
    "                radius: height / 2\n"
    "                color: Qt.rgba(1, 1, 1, 0.10)\n"
    "                border.width: passwordBox.activeFocus ? 2 : 1\n"
    "                border.color: passwordBox.activeFocus ? Kirigami.Theme.focusColor : Qt.rgba(1, 1, 1, 0.35)\n"
    "            }\n",
)

# Le bouton de déverrouillage, rond, à l'accent, comme celui de la connexion
remplacer(
    "contents/lockscreen/MainBlock.qml",
    "            icon.name: LayoutMirroring.enabled ? \"go-previous\" : \"go-next\"\n",
    "            icon.name: LayoutMirroring.enabled ? \"go-previous\" : \"go-next\"\n"
    "            // Ankh (D-052, lot 7c) : rond, à l'accent\n"
    "            background: Rectangle {\n"
    "                radius: width / 2\n"
    "                color: loginButton.down ? Qt.darker(Kirigami.Theme.focusColor, 1.2)\n"
    "                    : (loginButton.hovered ? Qt.lighter(Kirigami.Theme.focusColor, 1.1) : Kirigami.Theme.focusColor)\n"
    "            }\n",
)
