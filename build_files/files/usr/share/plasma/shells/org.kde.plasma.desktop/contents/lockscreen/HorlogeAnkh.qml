/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Horloge de l'écran de verrouillage d'Ankh (D-052, lot 7c ; mon choix du
// 2026-10-23, « Comme la connexion d'Ankh ») : celle de l'écran de connexion
// d'Ankh (D-043, /usr/share/sddm/themes/ankh/Main.qml), l'heure en Inter
// demi-grasse de 96 px et la date en 22 px dessous, pour un écran de 800 px
// de haut, en proportion au-delà. Mise à la place de l'horloge de KDE dans
// LockScreenUi.qml par build_files/plasma/adapter-plasma.py ; elle garde ce
// que WallpaperFader attend d'elle (son ombre, « shadow »).

import QtQuick

import org.kde.kirigami as Kirigami

Column {
    id: horloge

    property Item shadow
    property date maintenant: new Date()
    // Tailles proportionnelles à la hauteur de l'écran, comme à la connexion
    readonly property real k: Math.max(0.75, (parent ? parent.height : 800) / 800)

    spacing: 2 * k

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: horloge.maintenant = new Date()
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: horloge.maintenant.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        color: Kirigami.Theme.textColor
        font.family: "Inter"
        font.pixelSize: Math.round(96 * horloge.k)
        font.weight: Font.DemiBold
        font.letterSpacing: -2 * horloge.k
        renderType: Text.NativeRendering
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: {
            const jour = horloge.maintenant.toLocaleDateString(Qt.locale(), "dddd d MMMM");
            return jour.charAt(0).toUpperCase() + jour.slice(1);
        }
        color: Kirigami.Theme.textColor
        font.family: "Inter"
        font.pixelSize: Math.round(22 * horloge.k)
        renderType: Text.NativeRendering
    }
}
