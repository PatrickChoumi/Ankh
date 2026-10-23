/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Horloge d'Ankh dans la barre (D-052, lot 6b) : comme celle de Windows 11,
// l'heure et la date en 12 px sur deux lignes, alignées à droite, puis une
// cloche de 16 (barrée en mode Ne pas déranger). Heure et date suivent la
// langue du système (formats courts de la locale : 20:19 et 23/10/2026 en
// français). Au survol et volet ouvert, le rectangle des boutons de la barre
// (widgets/tasks, préfixe « hover », lot 4).

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

MouseArea {
    id: horloge

    property bool ouvert: false
    property bool nePasDeranger: false
    // L'heure, tenue par main.qml (l'infobulle la suit aussi)
    property date maintenant: new Date()

    // Largeur entière : un bord à demi-pixel serait flou
    implicitWidth: Math.ceil(rangee.implicitWidth) + 2 * (4 + 8)
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.maximumWidth: implicitWidth
    Layout.fillHeight: true
    hoverEnabled: true

    Accessible.role: Accessible.Button
    Accessible.name: heure.text + ", " + date.text

    KSvg.FrameSvgItem {
        anchors.fill: parent
        imagePath: "widgets/tasks"
        prefix: "hover"
        visible: horloge.containsMouse || horloge.ouvert
        opacity: horloge.pressed ? 0.7 : 1
    }

    Row {
        id: rangee
        anchors.centerIn: parent
        spacing: 8

        Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
                id: heure
                anchors.right: parent.right
                text: horloge.maintenant.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                font: Kirigami.Theme.smallFont
                color: Kirigami.Theme.textColor
            }
            Text {
                id: date
                anchors.right: parent.right
                text: horloge.maintenant.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
                font: Kirigami.Theme.smallFont
                color: Kirigami.Theme.textColor
            }
        }
        Kirigami.Icon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            source: horloge.nePasDeranger ? "notifications-disabled-symbolic" : "notifications-symbolic"
            isMask: true
            color: Kirigami.Theme.textColor
        }
    }
}
