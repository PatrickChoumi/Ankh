/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Petit bouton de texte du Démarrer d'Ankh (D-052, lot 5) : « Toutes les
// applications › », « ‹ Retour », lettres de la liste. 24 de haut, texte de
// 12 px, coins de 4 (A : bouton « All apps › » de 156×48 à 200 %). Plein, il
// a le fond et le contour des boutons de Windows 11 au repos ; sinon, il ne
// se voit qu'au survol. Le chevron est un glyphe de texte, pour suivre la
// police.

import QtQuick
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami

T.Button {
    id: bouton

    property string texte: ""
    property bool plein: false
    property bool gras: false
    // « › » après le texte, ou « ‹ » avant
    property bool chevronApres: false
    property bool chevronAvant: false
    property bool anneau: activeFocus && (focusReason === Qt.TabFocusReason || focusReason === Qt.BacktabFocusReason)

    implicitWidth: etiquette.implicitWidth + leftPadding + rightPadding
    implicitHeight: Mesures.boutonHauteur
    leftPadding: Mesures.boutonRetrait
    rightPadding: Mesures.boutonRetrait
    hoverEnabled: true
    text: texte
    Accessible.name: texte

    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    contentItem: Text {
        id: etiquette
        text: (bouton.chevronAvant ? "‹  " : "") + bouton.texte + (bouton.chevronApres ? "  ›" : "")
        textFormat: Text.PlainText
        font.family: Kirigami.Theme.defaultFont.family
        font.pixelSize: bouton.gras ? Mesures.texteCorps : Mesures.texteLegende
        font.weight: bouton.gras ? Font.DemiBold : Font.Normal
        color: Kirigami.Theme.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            visible: bouton.plein
            radius: Mesures.rayon
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false
            color: Qt.alpha(Kirigami.Theme.backgroundColor, 0.7)
            border.width: 1
            border.color: Qt.alpha(etiquette.color, Mesures.opaciteTrait)
        }
        Survol {
            anchors.fill: parent
            survole: bouton.hovered
            appuye: bouton.down
            anneau: bouton.anneau
        }
    }
}
