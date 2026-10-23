/*
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Champ de recherche du Démarrer d'Ankh, tiré de Header.qml de Kickoff
// (plasma-desktop 6.7.5) : il a le focus à l'ouverture, et le texte tapé
// n'importe où dans le volet y arrive (renvoi des touches, Demarrer.qml).
// Dessin de Windows 11 (B, Mesures.qml) : 576 × 40, coins de 4, loupe à
// gauche, trait de 2 px à la couleur d'accent en bas quand il a le focus.
// Flèche vers le bas : vers la vue affichée ; Entrée : lance son élément
// courant (le premier résultat pendant une recherche).

import QtQuick
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami

T.TextField {
    id: champ

    // Le volet (Demarrer.qml) ; Item, car il contient lui-même ce type
    property Item demarrer: null

    implicitWidth: Mesures.rechercheLargeur
    implicitHeight: Mesures.rechercheHauteur
    leftPadding: Mesures.rechercheRetrait + Mesures.rechercheIcone + Mesures.boutonRetrait
    rightPadding: Mesures.rechercheRetrait
    topPadding: 0
    bottomPadding: 0
    verticalAlignment: TextInput.AlignVCenter

    placeholderText: "Rechercher des applications, des paramètres et des documents"
    placeholderTextColor: Qt.alpha(Kirigami.Theme.textColor, Mesures.opaciteSecondaire)
    color: Kirigami.Theme.textColor
    selectionColor: Kirigami.Theme.highlightColor
    selectedTextColor: Kirigami.Theme.highlightedTextColor
    font.family: Kirigami.Theme.defaultFont.family
    font.pixelSize: Mesures.texteCorps
    selectByMouse: true
    focus: true

    Accessible.name: "Rechercher"
    Accessible.searchEdit: true

    // Texte renvoyé depuis une autre partie du volet : le champ prend le focus
    onTextEdited: forceActiveFocus(Qt.ShortcutFocusReason)

    Keys.onDownPressed: event => {
        if (champ.demarrer) {
            champ.demarrer.clavier = true;
            champ.demarrer.entrerDansVue();
        }
    }
    Keys.onReturnPressed: event => champ.demarrer?.lancerCourant()
    Keys.onEnterPressed: event => champ.demarrer?.lancerCourant()

    background: Item {
        // Fond : celui des vues du thème, translucide comme celui des
        // champs de Windows 11 (TextControlBackgroundRest de WinUI : blanc à
        // 70 % en clair), et un contour fin
        Rectangle {
            anchors.fill: parent
            radius: Mesures.rayon
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false
            color: Qt.alpha(Kirigami.Theme.backgroundColor, 0.7)
            border.width: 1
            border.color: Qt.alpha(champ.color, Mesures.opaciteTrait)
        }
        // Trait du bas, à la couleur d'accent avec le focus ; il suit
        // l'arrondi des coins, découpé dans un rectangle aux coins de 4
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: champ.activeFocus ? Mesures.rechercheTrait : 1
            clip: true

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: Mesures.rayon * 2
                radius: Mesures.rayon
                color: champ.activeFocus ? Kirigami.Theme.highlightColor : Qt.alpha(champ.color, 0.3)
            }
        }
        // Texte d'invite : les modèles de QtQuick.Templates ne le dessinent pas
        Text {
            x: champ.leftPadding
            width: parent.width - champ.leftPadding - champ.rightPadding
            anchors.verticalCenter: parent.verticalCenter
            visible: champ.length === 0 && champ.preeditText === ""
            text: champ.placeholderText
            textFormat: Text.PlainText
            elide: Text.ElideRight
            font: champ.font
            color: champ.placeholderTextColor
        }
        Kirigami.Icon {
            x: Mesures.rechercheRetrait
            anchors.verticalCenter: parent.verticalCenter
            width: Mesures.rechercheIcone
            height: Mesures.rechercheIcone
            source: "search"
            color: champ.color
            isMask: true
        }
    }
}
