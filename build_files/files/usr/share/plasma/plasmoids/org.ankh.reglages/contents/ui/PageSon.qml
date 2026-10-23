/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

// Page des sorties son des paramètres rapides (D-052, lot 6a) : comme
// derrière la flèche du volume de Windows 11. Un clic choisit la sortie par
// défaut, comme l'applet du son de Plasma (applet/ListItemBase.qml de
// plasma-pa 6.7.5, même licence : model.PulseObject.default).

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

PageListe {
    id: page

    required property var etat

    titre: "Sortie son"
    lien: "Plus de paramètres de son"
    onLienClique: etat.ouvrir("kcm_pulseaudio")

    Couleurs {
        id: couleurs
    }

    ListView {
        id: liste
        anchors.fill: parent
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        QQC2.ScrollBar.vertical: QQC2.ScrollBar {}
        model: page.etat.sorties

        delegate: Rectangle {
            id: sortie

            required property var model
            readonly property bool choisie: model.PulseObject.default

            x: page.marge - 8
            width: ListView.view.width - 2 * (page.marge - 8)
            height: 40
            radius: 4
            color: choisie || zone.pressed ? couleurs.discretAppui : (zone.containsMouse ? couleurs.discretSurvol : "transparent")

            // Pastille d'accent de 3×16 devant la sortie choisie, comme les
            // listes de Windows 11
            Rectangle {
                visible: sortie.choisie
                x: 0
                anchors.verticalCenter: parent.verticalCenter
                width: 3
                height: 16
                radius: 1.5
                color: couleurs.accent
            }

            MouseArea {
                id: zone
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sortie.model.PulseObject.default = true
            }

            Kirigami.Icon {
                x: 12
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                source: sortie.model.IconName || "audio-card"
                isMask: true
                color: Kirigami.Theme.textColor
            }
            Text {
                x: 40
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - x - 12
                text: sortie.model.Description
                elide: Text.ElideRight
                color: Kirigami.Theme.textColor
            }
        }
    }
}
