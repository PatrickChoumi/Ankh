/*
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later

    Écran de chargement de la session d'Ankh (D-037), adapté de celui de KDE
    (lookandfeel/org.kde.breeze/contents/splash/Splash.qml de
    https://invent.kde.org/plasma/plasma-workspace) : fond et logo d'Ankh,
    sans le logo ni le texte de Plasma. Sous le logo, une fine barre de
    progression qui avance à chaque étape du chargement, comme au démarrage
    d'un Mac (D-042), au lieu de l'indicateur qui tourne.
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
            // Taille fixe : la barre, placée dessous, ne bouge pas au chargement
            width: size
            height: size

            asynchronous: true
            source: "images/ankh-logo.svg"

            sourceSize.width: size
            sourceSize.height: size
        }

        // Barre de progression : le chargement de la session passe par six
        // étapes, la dernière fermant cet écran (ksplash/ksplashqml/splashapp.cpp
        // de plasma-workspace). Un rail discret, rempli du violet du logo.
        Rectangle {
            id: rail
            readonly property real progression: Math.min(Math.max(root.stage, 1), 6) / 6

            width: Kirigami.Units.gridUnit * 8
            height: Math.max(2, Math.round(Kirigami.Units.gridUnit / 6))
            radius: height / 2
            anchors.horizontalCenter: parent.horizontalCenter
            y: logo.y + logo.height + Kirigami.Units.gridUnit * 3
            color: Qt.rgba(1, 1, 1, 0.12)

            Rectangle {
                height: parent.height
                radius: parent.radius
                width: parent.width * rail.progression
                color: "#a78bfa"
                Behavior on width {
                    NumberAnimation {
                        duration: Kirigami.Units.veryLongDuration * 2
                        easing.type: Easing.OutCubic
                    }
                }
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
