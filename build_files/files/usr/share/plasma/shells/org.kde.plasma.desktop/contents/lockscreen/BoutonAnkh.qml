/*
    SPDX-FileCopyrightText: 2026 Ankh
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Bouton de l'écran de verrouillage d'Ankh (D-052, lot 10k) : le bouton rond
// translucide de la connexion et de la déconnexion d'Ankh
// (build_files/plasma/deconnexion/LogoutButton.qml, lot 7c), sans le compte à
// rebours de la déconnexion. Mis à la place des ActionButton de KDE (Veille,
// Hibernation, Changer d'utilisateur) dans LockScreenUi.qml par
// build_files/plasma/adapter-plasma.py : leurs icônes en couleur (ronds
// violets pleins de Fluent) deviennent des pictogrammes blancs, comme sur
// l'écran de verrouillage de Windows 11.

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.breeze.components

ActionButton {
    id: bouton

    // Sinon les couleurs des boutons du jeu de couleurs s'appliquent, et le
    // texte se lit mal avec un thème clair (comme dans KDE)
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    Layout.alignment: Qt.AlignTop

    // Rond de 64, icône de 28 au centre, nom à 8 sous le rond
    icon.width: 28
    icon.height: 28
    padding: 18
    spacing: padding + 8

    font.family: "Inter"
    font.pixelSize: 14
    font.underline: false
    opacity: 1

    background: Rectangle {
        implicitWidth: bouton.icon.width + bouton.padding * 2
        implicitHeight: bouton.icon.height + bouton.padding * 2
        // Taille fixe : le fond ne suit pas la largeur du nom
        width: implicitWidth
        height: implicitHeight
        radius: width / 2
        color: Qt.rgba(1, 1, 1, bouton.down ? 0.24 : (bouton.hovered ? 0.18 : 0.10))
        border.width: bouton.activeFocus ? 2 : 1
        border.color: bouton.activeFocus ? Kirigami.Theme.focusColor : Qt.rgba(1, 1, 1, 0.16)
        Behavior on color {
            ColorAnimation {
                duration: Kirigami.Units.shortDuration
            }
        }
    }

    contentItem: Column {
        spacing: bouton.spacing
        Kirigami.Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: bouton.icon.width
            implicitHeight: bouton.icon.height
            source: bouton.icon.name
            isMask: true
            color: "#e6edf3"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(implicitWidth, parent.width)
            text: bouton.Kirigami.MnemonicData.richTextLabel
            textFormat: Text.StyledText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
            font: bouton.font
            // Texte d'Ankh, ou texte discret (70 %) au repos, comme à la connexion
            color: bouton.hovered || bouton.activeFocus ? "#e6edf3" : Qt.rgba(230 / 255, 237 / 255, 243 / 255, 0.70)
        }
    }
}
