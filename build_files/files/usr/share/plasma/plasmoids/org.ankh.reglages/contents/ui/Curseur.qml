/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Curseur des paramètres rapides (D-052, lot 6a) : le Slider de Windows 11,
// aux mesures du style d'Ankh (lot 3, ankhmetrics.h, d'après
// CommonStyles/Slider_themeresources.xaml de WinUI) : rail de 4 aux bouts
// ronds, rempli d'accent jusqu'à la poignée, le reste de la couleur
// ControlStrongFillColorDefault ; poignée de 18, pleine
// (ControlSolidFillColorDefault), avec un point d'accent de 12, 14 au
// survol et 10 à l'appui. Les applets de Plasma ne passent pas par le style
// d'Ankh : le curseur est dessiné ici.

import QtQuick

import org.kde.kirigami as Kirigami

Item {
    id: curseur

    property int valeur: 0
    property bool actif: true
    property string nom

    signal deplace(int valeur)

    implicitHeight: 32

    Accessible.role: Accessible.Slider
    Accessible.name: nom

    Couleurs {
        id: couleurs
    }

    readonly property int poignee: 18
    readonly property real course: width - poignee
    // Pendant le glissement, la poignée suit la souris, sans attendre le système
    property int valeurAffichee: zone.pressed ? valeurGlissee : valeur
    property int valeurGlissee: valeur

    function valeurA(x: real): int {
        return Math.round(Math.max(0, Math.min(1, (x - poignee / 2) / course)) * 100);
    }

    Rectangle {
        id: rail
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - curseur.poignee
        x: curseur.poignee / 2
        height: 4
        radius: 2
        color: couleurs.sombre ? "#8bffffff" : "#72000000"
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: rail.x
        width: curseur.course * curseur.valeurAffichee / 100
        height: 4
        radius: 2
        color: curseur.actif ? couleurs.accent : couleurs.texteInactif
    }

    Rectangle {
        id: rond
        width: curseur.poignee
        height: curseur.poignee
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: curseur.course * curseur.valeurAffichee / 100
        // ControlSolidFillColorDefault et ControlElevationBorder
        color: couleurs.sombre ? "#454545" : "#ffffff"
        border.width: 1
        border.color: couleurs.sombre ? "#18ffffff" : "#29000000"

        Rectangle {
            readonly property int taille: zone.pressed ? 10 : (zone.containsMouse ? 14 : 12)
            anchors.centerIn: parent
            width: taille
            height: taille
            radius: taille / 2
            color: curseur.actif ? couleurs.accent : couleurs.texteInactif
            Behavior on width {
                NumberAnimation { duration: 83 }
            }
            Behavior on height {
                NumberAnimation { duration: 83 }
            }
        }
    }

    MouseArea {
        id: zone
        anchors.fill: parent
        hoverEnabled: true
        enabled: curseur.actif
        onPressed: mouse => {
            curseur.valeurGlissee = curseur.valeurA(mouse.x);
            curseur.deplace(curseur.valeurGlissee);
        }
        onPositionChanged: mouse => {
            if (pressed) {
                curseur.valeurGlissee = curseur.valeurA(mouse.x);
                curseur.deplace(curseur.valeurGlissee);
            }
        }
        onWheel: wheel => {
            curseur.deplace(Math.max(0, Math.min(100, curseur.valeur + (wheel.angleDelta.y > 0 ? 2 : -2))));
        }
    }

    Keys.onLeftPressed: curseur.deplace(Math.max(0, valeur - 2))
    Keys.onRightPressed: curseur.deplace(Math.min(100, valeur + 2))
}
