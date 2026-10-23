/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Petite flèche « › » des paramètres rapides (D-052, lot 6a) : celle des
// tuiles et des curseurs de Windows 11 (ChevronRight, 12 px), dessinée en
// deux traits, nette à toutes les échelles. vers : 1 à droite, -1 à gauche.

import QtQuick
import QtQuick.Shapes

Item {
    id: chevron

    property color couleur: "black"
    property int vers: 1

    implicitWidth: 12
    implicitHeight: 12

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeColor: chevron.couleur
            strokeWidth: 1.25
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            startX: chevron.vers > 0 ? 4.5 : 7.5
            startY: 2.5
            PathLine { x: chevron.vers > 0 ? 8 : 4; y: 6 }
            PathLine { x: chevron.vers > 0 ? 4.5 : 7.5; y: 9.5 }
        }
    }
}
