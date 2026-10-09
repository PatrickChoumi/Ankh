/*
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later

    Écran de chargement de la session d'Ankh (D-037), adapté de celui de KDE
    (lookandfeel/org.kde.breeze/contents/splash/Splash.qml de
    https://invent.kde.org/plasma/plasma-workspace) : fond et logo d'Ankh,
    sans le logo ni le texte de Plasma.
*/

import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    id: root
    // Fond du logo d'Ankh
    color: "#0d1117"

    property int stage

    onStageChanged: {
        if (stage == 2) {
            introAnimation.running = true;
        } else if (stage == 5) {
            introAnimation.target = busyIndicator;
            introAnimation.from = 1;
            introAnimation.to = 0;
            introAnimation.running = true;
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        Image {
            id: logo
            // Même place que l'avatar de l'écran de connexion et de verrouillage
            readonly property real size: Kirigami.Units.gridUnit * 8

            anchors.centerIn: parent

            asynchronous: true
            source: "images/ankh-logo.svg"

            sourceSize.width: size
            sourceSize.height: size
        }

        Image {
            id: busyIndicator
            // Au milieu de l'espace sous le logo
            y: parent.height - (parent.height - logo.y) / 2 - height/2
            anchors.horizontalCenter: parent.horizontalCenter
            asynchronous: true
            source: "images/busywidget.svgz"
            sourceSize.height: Kirigami.Units.gridUnit * 2
            sourceSize.width: Kirigami.Units.gridUnit * 2
            RotationAnimator on rotation {
                from: 0
                to: 360
                // Durée fixe, comme dans l'écran de KDE
                duration: 2000
                loops: Animation.Infinite
                // Pas d'animation si elles sont désactivées
                running: Kirigami.Units.longDuration > 1
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: Kirigami.Units.veryLongDuration * 2
        easing.type: Easing.InOutQuad
    }
}
