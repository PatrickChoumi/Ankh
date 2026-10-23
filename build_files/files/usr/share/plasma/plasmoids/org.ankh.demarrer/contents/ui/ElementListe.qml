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

// Une ligne du Démarrer d'Ankh, adaptée de KickoffListDelegate.qml de
// Kickoff (plasma-desktop 6.7.5) : icône, nom, et un détail en dessous s'il
// y en a un. Sert à « Toutes les applications » et aux résultats de
// recherche (icône de 24), et à « Recommandé » (icône de 32, deux lignes,
// cellule de 288 × 56 : Mesures.qml). Fond du survol en retrait de 16 px :
// l'icône tombe ainsi à 64 du bord du volet, comme dans Windows 11.

import QtQuick

import org.kde.kirigami as Kirigami

Element {
    id: ligneListe

    property int tailleIcone: Mesures.iconeListe
    readonly property bool detailVisible: detail !== "" && detail !== nom

    height: detailVisible ? Mesures.ligneListeDouble : Mesures.ligneListe
    padding: 0
    leftInset: Mesures.recommandeRetrait
    rightInset: Mesures.recommandeRetrait
    topInset: 2
    bottomInset: 2
    texteTronque: libelle.truncated
    imageGlissee: image

    contentItem: Item {
        Kirigami.Icon {
            id: image
            x: 2 * Mesures.recommandeRetrait
            anchors.verticalCenter: parent.verticalCenter
            width: ligneListe.tailleIcone
            height: ligneListe.tailleIcone
            animated: false
            source: ligneListe.retireEnGlissant ? "list-remove" : ligneListe.icone
        }

        Column {
            anchors.left: image.right
            anchors.leftMargin: Mesures.ecartAvatarNom
            anchors.right: parent.right
            anchors.rightMargin: 2 * Mesures.recommandeRetrait
            anchors.verticalCenter: parent.verticalCenter
            visible: !ligneListe.retireEnGlissant

            Text {
                id: libelle
                width: parent.width
                text: ligneListe.nom
                textFormat: Text.PlainText
                font.family: Kirigami.Theme.defaultFont.family
                font.pixelSize: Mesures.texteLegende
                color: Kirigami.Theme.textColor
                elide: Text.ElideRight
                maximumLineCount: 1
                wrapMode: Text.NoWrap
            }

            Text {
                width: parent.width
                visible: ligneListe.detailVisible
                text: ligneListe.detail
                textFormat: Text.PlainText
                font.family: Kirigami.Theme.defaultFont.family
                font.pixelSize: Mesures.texteLegende
                color: Kirigami.Theme.textColor
                opacity: Mesures.opaciteSecondaire
                elide: Text.ElideRight
                maximumLineCount: 1
                wrapMode: Text.NoWrap
            }
        }
    }
}
