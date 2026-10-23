/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Interrupteur des pages de liste (D-052, lot 6a) : le ToggleSwitch de
// Windows 11, comme celui du style d'Ankh (build_files/qqc2/SwitchIndicator.qml,
// lot 3) : piste de 40×20, pastille de 12, 14 au survol, 17×14 à l'appui ;
// éteint, piste voilée au bord marqué ; allumé, l'accent exact et une
// pastille blanche ou noire.

import QtQuick

import org.kde.kirigami as Kirigami

Item {
    id: interrupteur

    property bool allume: false

    signal bascule()

    implicitWidth: 40
    implicitHeight: 20

    Accessible.role: Accessible.CheckBox
    Accessible.checkable: true
    Accessible.checked: allume

    Couleurs {
        id: couleurs
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: interrupteur.allume
            ? (zone.pressed ? Qt.alpha(couleurs.accent, 0.8) : (zone.containsMouse ? Qt.alpha(couleurs.accent, 0.9) : couleurs.accent))
            : (zone.pressed ? (couleurs.sombre ? "#12ffffff" : "#18000000")
                : (zone.containsMouse ? (couleurs.sombre ? "#0bffffff" : "#0f000000") : (couleurs.sombre ? "#19000000" : "#06000000")))
        border.width: 1
        border.color: interrupteur.allume ? color : (couleurs.sombre ? "#8bffffff" : "#72000000")
    }

    Rectangle {
        readonly property int diametre: zone.containsMouse || zone.pressed ? 14 : 12
        x: Math.round(interrupteur.allume ? interrupteur.width - 10 - width / 2 : 10 - width / 2)
        anchors.verticalCenter: parent.verticalCenter
        width: zone.pressed ? 17 : diametre
        height: diametre
        radius: height / 2
        color: interrupteur.allume ? couleurs.surAccent : (couleurs.sombre ? "#c5ffffff" : "#9e000000")
        Behavior on x {
            NumberAnimation { duration: 167; easing.type: Easing.OutCubic }
        }
        Behavior on width {
            NumberAnimation { duration: 83 }
        }
    }

    MouseArea {
        id: zone
        anchors.fill: parent
        hoverEnabled: true
        onClicked: interrupteur.bascule()
    }
}
