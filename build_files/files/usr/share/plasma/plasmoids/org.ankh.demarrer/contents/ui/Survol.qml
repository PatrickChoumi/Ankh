/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Fond d'un élément du Démarrer d'Ankh (D-052, lot 5) : coins de 4, la
// couleur du texte très atténuée au survol et à l'appui, comme les boutons
// de la barre (style Plasma d'Ankh, lot 4) ; anneau de focus de Windows 11
// (trait de 2 dans la couleur du texte, trait intérieur de 1 dans celle du
// fond, D-052) quand l'élément est atteint au clavier. Couleurs du thème
// seulement.

import QtQuick

import org.kde.kirigami as Kirigami

Item {
    id: fond

    property bool survole: false
    property bool appuye: false
    // Élément courant d'une vue atteinte au clavier
    property bool selectionne: false
    property bool anneau: false

    Rectangle {
        anchors.fill: parent
        radius: Mesures.rayon
        color: Kirigami.Theme.textColor
        opacity: fond.appuye ? Mesures.opaciteAppui
            : ((fond.survole || fond.selectionne) ? Mesures.opaciteSurvol : 0)

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: fond.anneau
        radius: Mesures.rayon
        color: "transparent"
        border.width: Mesures.focusExterieur
        border.color: Kirigami.Theme.textColor

        Rectangle {
            anchors.fill: parent
            anchors.margins: Mesures.focusExterieur
            radius: Mesures.rayon - Mesures.focusExterieur
            color: "transparent"
            border.width: Mesures.focusInterieur
            border.color: Kirigami.Theme.backgroundColor
        }
    }
}
