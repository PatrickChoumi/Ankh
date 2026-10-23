/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Couleurs des applets d'Ankh (D-052, lots 6 et 7) : celles de Windows 11,
// en sombre et en clair, lues dans le code de WinUI
// (controls/dev/CommonStyles/Common_themeresources_any.xaml, commits 09cfc8f
// et 566a040 de microsoft-ui-xaml, licence MIT), au format #AARRGGBB, posées
// sur le fond du volet. L'accent est l'accent exact du jeu de couleurs
// (focusColor), avec du blanc ou du noir dessus, comme le style d'Ankh
// (lot 3, onAccentColor de ankhhelper.h).

import QtQuick

import org.kde.kirigami as Kirigami

QtObject {
    readonly property bool sombre: Kirigami.ColorUtils.brightnessForColor(Kirigami.Theme.backgroundColor) === Kirigami.ColorUtils.Dark

    readonly property color accent: Kirigami.Theme.focusColor
    // Blanc ou noir sur l'accent, le plus contrasté (luminance relative du W3C)
    readonly property color surAccent: {
        const lineaire = c => c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
        const l = 0.2126 * lineaire(accent.r) + 0.7152 * lineaire(accent.g) + 0.0722 * lineaire(accent.b);
        return 1.05 / (l + 0.05) >= (l + 0.05) / 0.05 ? "#ffffff" : "#000000";
    }

    // Boutons : ControlFillColorDefault, Secondary (survol), Tertiary
    // (appui), Disabled ; ControlStrokeColorDefault
    readonly property color controle: sombre ? "#0fffffff" : "#b3ffffff"
    readonly property color controleSurvol: sombre ? "#15ffffff" : "#80f9f9f9"
    readonly property color controleAppui: sombre ? "#08ffffff" : "#4df9f9f9"
    readonly property color controleInactif: sombre ? "#0bffffff" : "#4df9f9f9"
    readonly property color bordControle: sombre ? "#12ffffff" : "#0f000000"

    // Boutons discrets (icônes seules) : SubtleFillColorSecondary et Tertiary
    readonly property color discretSurvol: sombre ? "#0fffffff" : "#09000000"
    readonly property color discretAppui: sombre ? "#0affffff" : "#06000000"

    // Texte : TextFillColorSecondary et Disabled
    readonly property color texteSecondaire: sombre ? "#c5ffffff" : "#9e000000"
    readonly property color texteInactif: sombre ? "#5dffffff" : "#5c000000"

    // Séparateur (DividerStrokeColorDefault), carte (CardBackgroundFillColorDefault,
    // CardStrokeColorDefault)
    readonly property color separateur: sombre ? "#15ffffff" : "#0f000000"
    readonly property color carte: sombre ? "#0dffffff" : "#b3ffffff"
    readonly property color bordCarte: sombre ? "#19000000" : "#0f000000"

    // Contour de sélection au clavier (FocusStrokeColorOuter, 2 px, et
    // FocusStrokeColorInner, 1 px dedans : FocusVisualPrimaryThickness et
    // FocusVisualSecondaryThickness des styles de WinUI)
    readonly property color focusExterieur: sombre ? "#ffffffff" : "#e4000000"
    readonly property color focusInterieur: sombre ? "#b3000000" : "#b3ffffff"

    // Bande du bas du volet, un peu plus sombre que le volet : relevée sur
    // l'image de Microsoft en clair (227,238,249 contre 234,242,251)
    readonly property color pied: sombre ? "#1a000000" : "#08000000"
}
