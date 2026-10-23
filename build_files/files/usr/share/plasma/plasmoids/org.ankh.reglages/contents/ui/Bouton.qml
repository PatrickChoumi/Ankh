/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Bouton des paramètres rapides dans la barre d'Ankh (D-052, lot 6a ; mon
// choix du 2026-10-22 : un seul bouton) : comme celui de Windows 11, les
// icônes du réseau, du son et, s'il y a une batterie, de la batterie, à
// 16 px, espacées de 8, dans un même bouton. Au survol et volet ouvert, le
// rectangle des boutons de la barre (widgets/tasks du style Plasma d'Ankh,
// préfixe « hover », lot 4), aussi haut que les boutons des applications.

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

MouseArea {
    id: bouton

    required property var etat
    property bool ouvert: false

    // Rectangle du style à 4 px des côtés, puis 12 de part et d'autre des
    // icônes
    implicitWidth: icones.implicitWidth + 2 * (4 + 12)
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.maximumWidth: implicitWidth
    Layout.fillHeight: true
    hoverEnabled: true

    Accessible.role: Accessible.Button
    Accessible.name: "Paramètres rapides"

    KSvg.FrameSvgItem {
        anchors.fill: parent
        imagePath: "widgets/tasks"
        prefix: "hover"
        visible: bouton.containsMouse || bouton.ouvert
        opacity: bouton.pressed ? 0.7 : 1
    }

    Row {
        id: icones
        anchors.centerIn: parent
        spacing: 8
        Repeater {
            // L'état arrive juste après la création du bouton (main.qml)
            model: !bouton.etat ? []
                : [bouton.etat.iconeReseau, bouton.etat.iconeSon].concat(bouton.etat.batterieDisponible ? [bouton.etat.iconeBatterie] : [])
            delegate: Kirigami.Icon {
                required property string modelData
                width: 16
                height: 16
                source: modelData
                isMask: true
                color: Kirigami.Theme.textColor
            }
        }
    }
}
