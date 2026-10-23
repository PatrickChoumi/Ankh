/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Titre de section du Démarrer d'Ankh (« Épinglé », « Recommandé »,
// « Toutes les applications ») : 14 px, semi-gras, comme dans Windows 11
// (A, Mesures.qml). Il se place par sa ligne de base.

import QtQuick

import org.kde.kirigami as Kirigami

Text {
    textFormat: Text.PlainText
    font.family: Kirigami.Theme.defaultFont.family
    font.pixelSize: Mesures.titreTaille
    font.weight: Font.DemiBold
    color: Kirigami.Theme.textColor
    Accessible.role: Accessible.Heading
    Accessible.name: text
}
