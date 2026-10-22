/*
    SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Grille des lettres de « Toutes les applications », adaptée de
// SectionView.qml de Kickoff (plasma-desktop 6.7.5) : un clic sur une
// lettre ramène la liste à sa première application, comme dans Windows 11.
// Seules les lettres qui ont des applications sont présentes (SectionsModel
// de Kicker, rôles « section » et « firstIndex »). Cellules de 72 × 56
// (Mesures.qml, À VALIDER).

import QtQuick
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami

FocusScope {
    id: lettres

    // Le volet (Demarrer.qml) ; Item, car il contient lui-même ce type
    property Item demarrer: null
    property alias model: vue.model
    readonly property alias vue: vue
    // La lettre de l'en-tête cliqué devient la lettre courante
    property string lettreCourante: ""

    signal lettreChoisie(int premiereLigne)

    function placer(): void {
        for (let i = 0; i < vue.count; ++i) {
            if (vue.model.data(vue.model.index(i, 0), Qt.DisplayRole) === lettreCourante) {
                vue.currentIndex = i;
                return;
            }
        }
        vue.currentIndex = vue.count > 0 ? 0 : -1;
    }

    GridView {
        id: vue

        readonly property int colonnes: Math.max(1, Math.floor(width / cellWidth))

        anchors.fill: parent
        cellWidth: Mesures.lettreLargeur
        cellHeight: Mesures.lettreHauteur
        clip: true
        focus: true
        activeFocusOnTab: true
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: true
        Accessible.role: Accessible.Table
        Accessible.name: "Lettres"

        delegate: T.AbstractButton {
            id: case_
            required property int index
            required property string section
            required property int firstIndex

            width: vue.cellWidth
            height: vue.cellHeight
            hoverEnabled: true
            focusPolicy: Qt.NoFocus
            Accessible.name: section
            onClicked: lettres.lettreChoisie(firstIndex)

            contentItem: Text {
                text: case_.section.length === 1 ? case_.section.toUpperCase() : case_.section
                textFormat: Text.PlainText
                font.family: Kirigami.Theme.defaultFont.family
                font.pixelSize: Mesures.lettreTaille
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Survol {
                anchors.fill: parent
                anchors.margins: 2
                survole: case_.hovered
                appuye: case_.down
                selectionne: case_.GridView.isCurrentItem && vue.activeFocus && (lettres.demarrer?.clavier ?? false)
                anneau: selectionne
            }
        }

        Keys.onPressed: event => {
            if (lettres.demarrer) {
                lettres.demarrer.clavier = true;
            }
            if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && currentItem) {
                (currentItem as T.AbstractButton).clicked();
                event.accepted = true;
            }
        }
    }
}
