/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015-2018 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Une épingle du Démarrer d'Ankh, adaptée de KickoffGridDelegate.qml de
// Kickoff (plasma-desktop 6.7.5) : cellule de 96 × 84, icône de 32, libellé
// de 12 px sur une seule ligne, 8 px sous l'icône (Mesures.qml).

import QtQuick

import org.kde.kirigami as Kirigami

Element {
    id: epingle

    width: Mesures.celluleLargeur
    height: Mesures.celluleHauteur
    padding: 0
    texteTronque: libelle.truncated
    imageGlissee: image
    // Fond du survol un peu en retrait de la cellule (À VALIDER sur une capture)
    leftInset: 2
    rightInset: 2
    topInset: 2
    bottomInset: 2

    contentItem: Item {
        Kirigami.Icon {
            id: image
            x: Math.round((parent.width - width) / 2)
            y: Mesures.celluleRetrait
            width: Mesures.icone
            height: Mesures.icone
            animated: false
            source: epingle.retireEnGlissant ? "list-remove" : epingle.icone
        }

        Text {
            id: libelle
            anchors.top: image.bottom
            anchors.topMargin: Mesures.ecartIconeLibelle
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Mesures.boutonRetrait / 2
            anchors.rightMargin: Mesures.boutonRetrait / 2
            visible: !epingle.retireEnGlissant
            text: epingle.nom
            textFormat: Text.PlainText
            font.family: Kirigami.Theme.defaultFont.family
            font.pixelSize: Mesures.texteLegende
            color: Kirigami.Theme.textColor
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            maximumLineCount: 1
            wrapMode: Text.NoWrap
        }
    }
}
