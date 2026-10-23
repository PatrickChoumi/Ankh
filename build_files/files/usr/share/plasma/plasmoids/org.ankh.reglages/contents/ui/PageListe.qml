/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Page de liste des paramètres rapides (D-052, lot 6a) : ce que Windows 11
// montre derrière la flèche d'une tuile (Wi-Fi, Bluetooth) ou du volume
// (sorties son). En haut, le retour « ‹ », le titre et, s'il y en a un,
// l'interrupteur ; au milieu, la liste, qui défile ; en bas, le lien vers la
// page des réglages. Elle prend la place des tuiles et des curseurs, à la
// même hauteur : le volet ne change pas de taille.

import QtQuick

import org.kde.kirigami as Kirigami

Item {
    id: page

    property string titre
    property bool avecInterrupteur: false
    property bool interrupteur: false
    property string lien
    // Marge de gauche et de droite du contenu, celle des tuiles
    property int marge: 24
    default property alias contenu: zoneListe.data

    signal retour()
    signal bascule()
    signal lienClique()

    Couleurs {
        id: couleurs
    }

    // En-tête
    Item {
        id: entete
        width: parent.width
        height: 64

        BoutonDiscret {
            id: retour
            x: page.marge - 8
            anchors.verticalCenter: parent.verticalCenter
            infobulle: "Retour"
            onClique: page.retour()
            Chevron {
                anchors.centerIn: parent
                vers: -1
                couleur: Kirigami.Theme.textColor
            }
        }
        Text {
            anchors.left: retour.right
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: page.titre
            font.family: Kirigami.Theme.defaultFont.family
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: Kirigami.Theme.textColor
        }
        Interrupteur {
            visible: page.avecInterrupteur
            anchors.right: parent.right
            anchors.rightMargin: page.marge
            anchors.verticalCenter: parent.verticalCenter
            allume: page.interrupteur
            onBascule: page.bascule()
        }
    }

    // Liste
    Item {
        id: zoneListe
        anchors {
            top: entete.bottom
            bottom: lienPage.top
            left: parent.left
            right: parent.right
            bottomMargin: 8
        }
        clip: true
    }

    // Lien vers les réglages
    Rectangle {
        id: lienPage
        anchors {
            bottom: parent.bottom
            bottomMargin: 8
            left: parent.left
            leftMargin: page.marge - 8
        }
        width: texteLien.implicitWidth + 16
        height: 32
        radius: 4
        color: zoneLien.pressed ? couleurs.discretAppui : (zoneLien.containsMouse ? couleurs.discretSurvol : "transparent")
        Text {
            id: texteLien
            anchors.centerIn: parent
            text: page.lien
            color: Kirigami.Theme.linkColor
        }
        MouseArea {
            id: zoneLien
            anchors.fill: parent
            hoverEnabled: true
            onClicked: page.lienClique()
        }
    }
}
