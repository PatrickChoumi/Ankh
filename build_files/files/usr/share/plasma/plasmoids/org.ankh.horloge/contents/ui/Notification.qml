/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Une notification de l'historique (D-052, lot 6b), comme les cartes du
// centre de notifications de Windows 11 : carte aux coins de 8
// (CardBackgroundFillColorDefault, CardStrokeColorDefault de WinUI) ; en
// haut, l'icône et le nom de l'application, l'heure, et la croix au survol ;
// puis le titre en semi-gras et le texte. Un clic lance l'action par défaut
// de la notification, s'il y en a une.

import QtQuick

import org.kde.kirigami as Kirigami

import org.ankh.commun

Rectangle {
    id: carte

    required property string summary
    required property string body
    required property string applicationName
    required property string applicationIconName
    required property var created
    required property bool hasDefaultAction
    required property bool closable

    signal fermee()
    signal activee()

    implicitHeight: colonne.implicitHeight + 24
    radius: 8
    color: zone.containsMouse ? couleurs.controleSurvol : couleurs.carte
    border.width: 1
    border.color: couleurs.bordCarte

    Couleurs {
        id: couleurs
    }

    MouseArea {
        id: zone
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: carte.hasDefaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (carte.hasDefaultAction) carte.activee()
    }

    Column {
        id: colonne
        x: 12
        y: 12
        width: parent.width - 24
        spacing: 4

        Item {
            width: parent.width
            height: 20
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Kirigami.Icon {
                    width: 16
                    height: 16
                    source: carte.applicationIconName || "preferences-desktop-notification"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: carte.applicationName
                    font: Kirigami.Theme.smallFont
                    color: couleurs.texteSecondaire
                }
            }
            Text {
                visible: !fermer.visible
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                // L'heure pour aujourd'hui, la date avant, comme Windows 11
                text: {
                    if (!carte.created) {
                        return "";
                    }
                    return carte.created.toDateString() === new Date().toDateString()
                        ? carte.created.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                        : carte.created.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
                }
                font: Kirigami.Theme.smallFont
                color: couleurs.texteSecondaire
            }
            BoutonDiscret {
                id: fermer
                // Au survol de la carte (Qt Quick donne le survol à tous les
                // éléments sous la souris : la carte le garde sur la croix)
                visible: carte.closable && zone.containsMouse
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                icone: "window-close-symbolic"
                infobulle: "Fermer"
                onClique: carte.fermee()
            }
        }
        Text {
            width: parent.width
            text: carte.summary
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            font.family: Kirigami.Theme.defaultFont.family
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: Kirigami.Theme.textColor
        }
        Text {
            visible: text !== ""
            width: parent.width
            text: carte.body
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
            font: Kirigami.Theme.smallFont
            color: couleurs.texteSecondaire
        }
    }
}
