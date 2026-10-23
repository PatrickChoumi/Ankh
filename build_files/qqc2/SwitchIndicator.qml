/*
    SPDX-FileCopyrightText: 2022 Tanbir Jishan <tantalising007@gmail.com>
    SPDX-FileCopyrightText: 2017 The Qt Company Ltd.
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-or-later
*/

// Interrupteur d'Ankh (D-052, lot 3), à la place de private/SwitchIndicator.qml
// de qqc2-desktop-style 6.31, dont il garde l'interface (control, handle).
// Il dessine le ToggleSwitch de Windows 11 (WinUI, CommonStyles/
// ToggleSwitch_themeresources.xaml et Common_themeresources_any.xaml) :
// - piste de 40×20, arrondie, bord de 1 px ;
// - éteint : piste voilée (ControlAltFillColor), bord et pastille marqués
//   (ControlStrongStrokeColorDefault, TextFillColorSecondary) ;
// - allumé : piste et bord de la couleur d'accent, plus légère au survol et
//   à l'appui (AccentFillColorSecondary et Tertiary), pastille blanche ou
//   noire, la plus contrastée sur l'accent (TextOnAccentFillColorPrimary) ;
//   l'accent est l'accent exact (focusColor), et non la sélection de KDE,
//   comme dans le style d'Ankh (accentColor de ankhhelper.h) ;
// - pastille de 12 px, 14 au survol, 17×14 à l'appui, centrée à 10 px du
//   bord de départ puis de celui d'arrivée.

import QtQuick
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

Item {
    id: indicator
    implicitWidth: 40
    implicitHeight: 20
    layer.enabled: control.opacity < 1.0

    property T.AbstractButton control
    property alias handle: handle

    Kirigami.Theme.colorSet: Kirigami.Theme.Button
    Kirigami.Theme.inherit: false

    QtObject {
        id: couleurs

        readonly property bool sombre: Kirigami.ColorUtils.brightnessForColor(Kirigami.Theme.backgroundColor) === Kirigami.ColorUtils.Dark
        readonly property bool active: indicator.control.enabled
        readonly property bool survol: active && indicator.control.hovered
        readonly property bool appui: active && indicator.control.pressed

        // Couleurs au format #AARRGGBB, celles de Windows 11 en sombre et en clair
        readonly property color voile: !active ? "transparent"
            : appui ? (sombre ? "#12ffffff" : "#18000000")
            : survol ? (sombre ? "#0bffffff" : "#0f000000")
            : (sombre ? "#19000000" : "#06000000")
        readonly property color bordEteint: active ? (sombre ? "#8bffffff" : "#72000000") : (sombre ? "#28ffffff" : "#37000000")
        readonly property color pastilleEteinte: active ? (sombre ? "#c5ffffff" : "#9e000000") : (sombre ? "#5dffffff" : "#5c000000")
        readonly property color accentExact: Kirigami.Theme.focusColor
        // Blanc ou noir sur l'accent, le plus contrasté (luminance relative
        // du W3C), comme onAccentColor du style d'Ankh
        readonly property color surAccent: {
            const lineaire = c => c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
            const l = 0.2126 * lineaire(accentExact.r) + 0.7152 * lineaire(accentExact.g) + 0.0722 * lineaire(accentExact.b);
            return 1.05 / (l + 0.05) >= (l + 0.05) / 0.05 ? "#ffffff" : "#000000";
        }
        readonly property color accent: !active ? (sombre ? "#28ffffff" : "#37000000")
            : appui ? Qt.alpha(accentExact, 0.8)
            : survol ? Qt.alpha(accentExact, 0.9)
            : accentExact
        readonly property color pastilleAllumee: active ? surAccent : (sombre ? "#87ffffff" : "#ffffff")
    }

    Rectangle {
        id: piste

        anchors.fill: parent
        radius: height / 2
        color: indicator.control.checked ? couleurs.accent : couleurs.voile
        border.width: 1
        border.color: indicator.control.checked ? couleurs.accent : couleurs.bordEteint
    }

    Rectangle {
        id: handle

        readonly property real diametre: couleurs.survol || couleurs.appui ? 14 : 12

        // visualPosition va de 0 à 1, suit le glissement et l'écriture de
        // droite à gauche
        x: Math.round(10 + indicator.control.visualPosition * (indicator.width - 20) - width / 2)
        anchors.verticalCenter: parent.verticalCenter
        width: couleurs.appui ? 17 : diametre
        height: diametre
        radius: height / 2
        color: indicator.control.checked ? couleurs.pastilleAllumee : couleurs.pastilleEteinte

        Behavior on x {
            enabled: !indicator.control.pressed && Kirigami.Units.shortDuration > 0
            SmoothedAnimation {
                duration: Kirigami.Units.shortDuration
            }
        }
        // ControlFasterAnimationDuration de Windows 11 : 83 ms
        Behavior on width {
            enabled: Kirigami.Units.shortDuration > 0
            NumberAnimation {
                duration: 83
            }
        }
        Behavior on height {
            enabled: Kirigami.Units.shortDuration > 0
            NumberAnimation {
                duration: 83
            }
        }
    }
}
