/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Bouton discret des paramètres rapides (D-052, lot 6a) : une icône de 16,
// sans fond au repos ; au survol et à l'appui, le fond discret de Windows 11
// (SubtleFillColorSecondary et Tertiary), coins de 4. Avec une flèche, il
// ouvre une liste (sortie son).

import QtQuick

import org.kde.kirigami as Kirigami

Rectangle {
    id: bouton

    property string icone
    property bool fleche: false
    property string infobulle

    signal clique()

    implicitWidth: fleche ? 44 : 32
    implicitHeight: 32
    radius: 4
    color: zone.pressed ? couleurs.discretAppui : (zone.containsMouse ? couleurs.discretSurvol : "transparent")

    Accessible.role: Accessible.Button
    Accessible.name: infobulle

    Couleurs {
        id: couleurs
    }

    Row {
        anchors.centerIn: parent
        spacing: 4
        Kirigami.Icon {
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            source: bouton.icone
            isMask: true
            color: Kirigami.Theme.textColor
        }
        Chevron {
            visible: bouton.fleche
            anchors.verticalCenter: parent.verticalCenter
            couleur: Kirigami.Theme.textColor
        }
    }

    MouseArea {
        id: zone
        anchors.fill: parent
        hoverEnabled: true
        onClicked: bouton.clique()
    }
}
