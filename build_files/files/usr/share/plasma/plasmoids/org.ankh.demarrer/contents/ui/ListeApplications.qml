/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2015-2018 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Liste du Démarrer d'Ankh, adaptée de KickoffListView.qml de Kickoff
// (plasma-desktop 6.7.5) : toutes les applications, par ordre alphabétique
// avec un en-tête par lettre (un clic sur une lettre ouvre la grille des
// lettres), ou les résultats de la recherche, groupés par lanceur de KRunner
// (« Applications », « Paramètres système »…). Lignes de 40, icônes de 24
// (Mesures.qml, À VALIDER).

import QtQuick

import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

FocusScope {
    id: liste

    // Le volet (Demarrer.qml) ; Item, car il contient lui-même ce type
    property Item demarrer: null
    property alias model: vue.model
    readonly property alias vue: vue
    readonly property alias count: vue.count
    // Sections : « FirstCharacter » pour les lettres, « FullString » pour
    // les groupes de résultats
    property string sectionPropriete: "group"
    property int sectionCritere: ViewSection.FirstCharacter
    // Résultats de recherche : le premier est montré même sans clavier,
    // comme le « meilleur résultat » de Windows
    property bool recherche: false
    readonly property bool selectionVisible: recherche || (vue.activeFocus && demarrer !== null && demarrer.clavier)

    // Clic sur l'en-tête d'une lettre
    signal lettresDemandees(string lettre)
    // Flèche vers le haut sur la première ligne
    signal sortieHaut()

    function reinitialiser(): void {
        vue.currentIndex = vue.count > 0 ? 0 : -1;
        vue.positionViewAtBeginning();
    }

    function allerA(ligne: int): void {
        vue.positionViewAtIndex(ligne, ListView.Beginning);
        vue.currentIndex = ligne;
    }

    ListView {
        id: vue

        anchors.fill: parent
        clip: true
        focus: true
        activeFocusOnTab: true
        currentIndex: count > 0 ? 0 : -1
        pixelAligned: true
        reuseItems: false
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: false
        highlightFollowsCurrentItem: false
        Accessible.role: Accessible.List

        onCountChanged: {
            if (!activeFocus) {
                currentIndex = count > 0 ? 0 : -1;
            }
        }

        delegate: ElementListe {
            required property var model

            width: vue.width
            demarrer: liste.demarrer
            modele: vue.model
            nom: model.display ?? ""
            icone: model.decoration ?? null
            // Le détail ne sert qu'aux résultats qui ne sont pas des
            // applications (dossier d'un fichier, réglage…)
            detail: liste.recherche ? (model.description ?? "") : ""
            favori: model.favoriteId ?? ""
            adresse: model.url ?? ""
            listeActions: model.actionList ?? null
            aActions: model.hasActionList ?? false
            separateur: model.isSeparator ?? false
            selectionVisible: liste.selectionVisible
        }

        section.property: liste.sectionPropriete
        section.criteria: liste.sectionCritere
        section.delegate: EnTete {}

        component EnTete: Item {
            id: entete
            required property string section

            width: vue.width
            height: Mesures.ligneListe

            // Lettre : un bouton qui ouvre la grille des lettres ; groupe de
            // résultats : un simple titre
            Bouton {
                id: lettre
                visible: !liste.recherche
                // La lettre s'aligne sur les icônes, à 64 du bord du volet
                x: 2 * Mesures.recommandeRetrait - leftPadding
                anchors.verticalCenter: parent.verticalCenter
                height: Mesures.ligneListe - 8
                texte: entete.section.length === 1 ? entete.section.toUpperCase() : entete.section
                gras: true
                focusPolicy: Qt.NoFocus
                onClicked: liste.lettresDemandees(entete.section)
                Accessible.name: "Lettre " + texte + " : afficher toutes les lettres"
            }
            Text {
                visible: liste.recherche
                x: 2 * Mesures.recommandeRetrait
                anchors.verticalCenter: parent.verticalCenter
                text: entete.section
                textFormat: Text.PlainText
                font.family: Kirigami.Theme.defaultFont.family
                font.pixelSize: Mesures.texteCorps
                font.weight: Font.DemiBold
                color: Kirigami.Theme.textColor
            }
        }

        // Barre de défilement dans la marge droite du volet, comme Windows 11
        PC3.ScrollBar.vertical: PC3.ScrollBar {
            parent: liste
            x: liste.width + Math.round((Mesures.bordGrille - width) / 2)
            height: liste.height
        }

        Keys.onMenuPressed: event => {
            const element = currentItem as Element;
            if (element !== null) {
                element.ouvrirMenu(undefined, undefined);
            }
        }

        // Navigation au clavier de Kickoff, en sautant les séparateurs
        Keys.onPressed: event => {
            if (liste.demarrer) {
                liste.demarrer.clavier = true;
            }
            const premier = currentIndex <= 0;
            const dernier = currentIndex === count - 1;
            switch (event.key) {
            case Qt.Key_Up:
                if (premier) {
                    liste.sortieHaut();
                } else {
                    decrementCurrentIndex();
                    if ((currentItem as Element)?.separateur) {
                        decrementCurrentIndex();
                    }
                    positionViewAtIndex(currentIndex, ListView.Contain);
                }
                event.accepted = true;
                break;
            case Qt.Key_Down:
                if (!dernier) {
                    incrementCurrentIndex();
                    if ((currentItem as Element)?.separateur) {
                        incrementCurrentIndex();
                    }
                    positionViewAtIndex(currentIndex, ListView.Contain);
                }
                event.accepted = true;
                break;
            case Qt.Key_Home:
                currentIndex = 0;
                positionViewAtBeginning();
                event.accepted = true;
                break;
            case Qt.Key_End:
                currentIndex = count - 1;
                positionViewAtEnd();
                event.accepted = true;
                break;
            case Qt.Key_PageUp:
            case Qt.Key_PageDown: {
                const pas = Math.max(1, Math.floor(height / Mesures.ligneListe) - 1);
                currentIndex = Math.max(0, Math.min(count - 1,
                    currentIndex + (event.key === Qt.Key_PageUp ? -pas : pas)));
                positionViewAtIndex(currentIndex, ListView.Contain);
                event.accepted = true;
                break;
            }
            case Qt.Key_Return:
            case Qt.Key_Enter:
            case Qt.Key_Space:
                (currentItem as Element)?.lancer();
                event.accepted = true;
                break;
            }
        }
    }
}
