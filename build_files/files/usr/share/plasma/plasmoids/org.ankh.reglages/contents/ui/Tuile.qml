/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Tuile des paramètres rapides (D-052, lot 6a), comme celles de Windows 11,
// mesurées sur une image officielle de Microsoft (billet Windows Insider de
// la build 25967, image quick-settings-pagination2.png, à 150 %, recherche
// du lot 6) : bouton de 96×48 aux coins de 4 (ControlCornerRadius), icône
// de 16 au centre ; libellé de 12 px centré sous le bouton, sa ligne à 8 px
// du bouton, sur deux lignes au plus. Éteinte : le fond et le bord des boutons de Windows 11
// (ControlFillColorDefault, ControlStrokeColorDefault). Allumée : l'accent
// exact, et l'icône blanche ou noire, la plus contrastée (comme le style
// d'Ankh, lot 3). Une tuile à flèche (Wi-Fi, Bluetooth) est en deux parties :
// l'icône allume ou éteint, la flèche ouvre la liste.

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.ankh.commun

Item {
    id: tuile

    required property string texte
    required property string icone
    property bool active: false
    property bool fleche: false
    property bool disponible: true

    signal basculee()
    signal ouverte()

    implicitWidth: 96
    implicitHeight: 96

    Accessible.role: Accessible.Button
    Accessible.name: texte
    Accessible.checkable: true
    Accessible.checked: active

    Couleurs {
        id: couleurs
    }

    // Bouton : partie gauche (toute la tuile sans flèche) et partie droite
    Rectangle {
        id: bouton
        width: 96
        height: 48
        radius: 4
        color: !tuile.disponible ? couleurs.controleInactif
            : tuile.active ? (zoneGauche.pressed || zoneDroite.pressed ? Qt.alpha(couleurs.accent, 0.8)
                : (zoneGauche.containsMouse || zoneDroite.containsMouse ? Qt.alpha(couleurs.accent, 0.9) : couleurs.accent))
            : (zoneGauche.pressed || zoneDroite.pressed ? couleurs.controleAppui
                : (zoneGauche.containsMouse || zoneDroite.containsMouse ? couleurs.controleSurvol : couleurs.controle))
        border.width: tuile.active ? 0 : 1
        border.color: couleurs.bordControle

        Row {
            anchors.centerIn: parent
            spacing: 10
            Kirigami.Icon {
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                source: tuile.icone
                isMask: true
                color: tuile.active ? couleurs.surAccent : (tuile.disponible ? Kirigami.Theme.textColor : couleurs.texteInactif)
            }
            Chevron {
                visible: tuile.fleche
                anchors.verticalCenter: parent.verticalCenter
                couleur: tuile.active ? couleurs.surAccent : Kirigami.Theme.textColor
            }
        }

        MouseArea {
            id: zoneGauche
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                right: tuile.fleche ? zoneDroite.left : parent.right
            }
            enabled: tuile.disponible
            hoverEnabled: true
            onClicked: tuile.basculee()
        }
        MouseArea {
            id: zoneDroite
            visible: tuile.fleche
            width: tuile.fleche ? 40 : 0
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            enabled: tuile.disponible
            hoverEnabled: true
            onClicked: tuile.ouverte()
        }
    }

    Text {
        anchors {
            top: bouton.bottom
            topMargin: 8
            horizontalCenter: bouton.horizontalCenter
        }
        width: 104
        horizontalAlignment: Text.AlignHCenter
        // Deux lignes au plus : les libellés français sont plus longs que
        // ceux de Windows 11 (« Économie d'énergie »)
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
        lineHeightMode: Text.FixedHeight
        lineHeight: 16
        text: tuile.texte
        font: Kirigami.Theme.smallFont
        color: tuile.disponible ? Kirigami.Theme.textColor : couleurs.texteInactif
    }
}
