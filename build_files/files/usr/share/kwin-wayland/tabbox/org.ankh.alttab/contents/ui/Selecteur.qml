/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Alt+Tab d'Ankh (D-052, lot 7a ; mon choix du 2026-10-23, « Comme
// Windows 11 ») : les fenêtres ouvertes dans un panneau centré, chacune avec
// son icône et son titre au-dessus d'une vignette vivante ; la fenêtre
// choisie est entourée du contour de sélection de WinUI (2 px dehors, 1 px
// dedans, coins de 8 : OverlayCornerRadius) sur un fond discret ; la croix
// de fermeture paraît sur la fenêtre choisie ou survolée.
//
// Ce fichier ne dépend pas de KWin : main.qml lui donne la liste des
// fenêtres (le modèle de KWin, rôles caption, icon, windowId et closeable)
// et la vignette (KWin.WindowThumbnail), pour que la construction puisse le
// créer et le vérifier hors écran avec de fausses fenêtres
// (build_files/plasma/alttab-sonde.qml).
//
// Mesures : coins et couleurs de WinUI ; tailles et espacements observés sur
// Windows 11, sans image officielle mesurable (le blog des Windows Insiders
// refuse les accès automatiques), À VALIDER : marge de 12, éléments espacés
// de 8, rembourrés de 8, titre de 24 en 12 px, vignettes de 160 de haut au
// plus, plus petites (96 au moins) pour tenir sur une rangée.

import QtQuick

import org.kde.kirigami as Kirigami

import org.ankh.commun

FocusScope {
    id: selecteur

    // Liste des fenêtres (rôles caption, icon, windowId, closeable)
    required property var modele
    // Fenêtre choisie
    property int courant: 0
    // Place disponible sur l'écran
    property int largeurMax: 1152
    property int hauteurMax: 640
    property real rapportEcran: 16 / 10
    // Vignette d'une fenêtre ; elle reçoit son identifiant dans « fenetre »
    property Component vignette
    property bool peutFermer: true

    signal choisi(int index)
    signal active(int index)
    signal ferme(int index)

    readonly property int marge: 12
    readonly property int espacement: 8
    readonly property int remplissage: 8
    readonly property int hauteurTitre: 24
    readonly property int ecartTitre: 4

    readonly property int nombre: grille.count
    readonly property int largeurUtile: largeurMax - 2 * marge
    // Vignettes de 160 de haut au plus, plus petites pour tenir sur une
    // rangée, jusqu'à 96 ; au-delà, plusieurs rangées
    readonly property int hauteurVignette: {
        const n = Math.max(1, nombre);
        const largeurParFenetre = (largeurUtile - (n - 1) * espacement) / n - 2 * remplissage;
        return Math.round(Math.max(96, Math.min(160, largeurParFenetre / rapportEcran)));
    }
    readonly property int largeurVignette: Math.round(hauteurVignette * rapportEcran)
    readonly property int largeurElement: largeurVignette + 2 * remplissage
    readonly property int hauteurElement: remplissage + hauteurTitre + ecartTitre + hauteurVignette + remplissage
    readonly property int colonnes: Math.max(1, Math.min(nombre,
        Math.floor((largeurUtile + espacement) / (largeurElement + espacement))))
    readonly property int rangees: Math.max(1, Math.ceil(nombre / colonnes))
    readonly property int rangeesVisibles: Math.max(1, Math.min(rangees,
        Math.floor((hauteurMax - 2 * marge + espacement) / (hauteurElement + espacement))))

    implicitWidth: nombre === 0 ? 320 : 2 * marge + colonnes * largeurElement + (colonnes - 1) * espacement
    implicitHeight: nombre === 0 ? 120 : 2 * marge + rangeesVisibles * hauteurElement + (rangeesVisibles - 1) * espacement
    width: implicitWidth
    height: implicitHeight
    focus: true

    function deplacer(pas: int): void {
        if (nombre === 0) {
            return;
        }
        let index = courant + pas;
        if (Math.abs(pas) === 1) {
            index = (index + nombre) % nombre;
        } else {
            index = Math.max(0, Math.min(nombre - 1, index));
        }
        selecteur.choisi(index);
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Left) {
            deplacer(-1);
        } else if (event.key === Qt.Key_Right) {
            deplacer(1);
        } else if (event.key === Qt.Key_Up) {
            deplacer(-colonnes);
        } else if (event.key === Qt.Key_Down) {
            deplacer(colonnes);
        } else {
            return;
        }
        event.accepted = true;
    }

    Couleurs {
        id: couleurs
    }

    GridView {
        id: grille
        x: selecteur.marge
        y: selecteur.marge
        // La dernière colonne et la dernière rangée n'ont pas d'espacement
        // après elles : les cellules en ont un, qui dépasse dans la marge
        width: selecteur.colonnes * cellWidth
        height: selecteur.rangeesVisibles * cellHeight
        cellWidth: selecteur.largeurElement + selecteur.espacement
        cellHeight: selecteur.hauteurElement + selecteur.espacement
        clip: selecteur.rangees > selecteur.rangeesVisibles
        interactive: false
        model: selecteur.modele
        currentIndex: selecteur.courant
        highlightFollowsCurrentItem: false
        onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)

        delegate: Item {
            id: element

            required property int index
            required property string caption
            required property var icon
            required property var windowId
            required property bool closeable

            readonly property bool estCourant: GridView.isCurrentItem

            width: selecteur.largeurElement
            height: selecteur.hauteurElement

            Accessible.name: caption
            Accessible.role: Accessible.ListItem

            // Fond discret sur la fenêtre choisie et au survol
            // (SubtleFillColorSecondary)
            Rectangle {
                anchors.fill: parent
                radius: 8
                color: element.estCourant || zone.containsMouse ? couleurs.discretSurvol : "transparent"
            }

            MouseArea {
                id: zone
                anchors.fill: parent
                hoverEnabled: true
                onClicked: selecteur.active(element.index)
            }

            // Icône et titre
            Row {
                x: selecteur.remplissage
                y: selecteur.remplissage
                height: selecteur.hauteurTitre
                spacing: 8
                Kirigami.Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    source: element.icon
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    // La place de la croix reste libre à droite
                    width: selecteur.largeurVignette - 16 - 8 - 24
                    text: element.caption
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    font: Kirigami.Theme.smallFont
                    color: Kirigami.Theme.textColor
                }
            }

            // Vignette vivante de la fenêtre
            Item {
                x: selecteur.remplissage
                y: selecteur.remplissage + selecteur.hauteurTitre + selecteur.ecartTitre
                width: selecteur.largeurVignette
                height: selecteur.hauteurVignette
                Loader {
                    anchors.fill: parent
                    sourceComponent: selecteur.vignette
                    onLoaded: item.fenetre = Qt.binding(() => element.windowId)
                }
            }

            BoutonDiscret {
                visible: selecteur.peutFermer && element.closeable && (element.estCourant || zone.containsMouse)
                anchors.right: parent.right
                anchors.rightMargin: selecteur.remplissage - 4
                y: selecteur.remplissage
                width: 24
                height: 24
                icone: "window-close-symbolic"
                infobulle: "Fermer"
                onClique: selecteur.ferme(element.index)
            }

            // Contour de sélection de WinUI : 2 px dehors, 1 px dedans
            Rectangle {
                visible: element.estCourant
                anchors.fill: parent
                radius: 8
                color: "transparent"
                border.width: 2
                border.color: couleurs.focusExterieur
            }
            Rectangle {
                visible: element.estCourant
                anchors.fill: parent
                anchors.margins: 2
                radius: 6
                color: "transparent"
                border.width: 1
                border.color: couleurs.focusInterieur
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: selecteur.nombre === 0
        text: "Aucune fenêtre ouverte"
        color: couleurs.texteSecondaire
    }
}
