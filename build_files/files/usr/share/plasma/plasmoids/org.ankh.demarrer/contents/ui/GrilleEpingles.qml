/*
    SPDX-FileCopyrightText: 2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Grille des épingles du Démarrer d'Ankh, adaptée de KickoffGridView.qml,
// DropAreaGridView.qml et KickoffDropArea.qml de Kickoff (plasma-desktop
// 6.7.5) : 6 colonnes × 3 rangées de 96 × 84 (Mesures.qml). Au-delà de 18
// épingles, la grille se tourne page par page, comme dans Windows 11 : à la
// molette, au clavier ou par les points à droite. On réordonne les épingles
// en les glissant (moveRow), ou au clavier avec Ctrl+Maj+flèches, comme dans
// Kickoff.

import QtQuick

import org.kde.kirigami as Kirigami

FocusScope {
    id: grille

    // Le volet (Demarrer.qml) ; Item, car il contient lui-même ce type
    property Item demarrer: null
    property alias model: vue.model
    readonly property alias vue: vue
    readonly property alias count: vue.count
    // Montrer l'élément courant (vue atteinte au clavier)
    readonly property bool selectionVisible: vue.activeFocus && demarrer !== null && demarrer.clavier

    readonly property int parPage: Mesures.colonnes * Mesures.rangees
    readonly property int pages: Math.max(1, Math.ceil(vue.count / parPage))
    property int page: 0

    // Flèche vers le haut depuis la première rangée, vers le bas depuis la
    // dernière : la page d'accueil passe le focus au voisin
    signal sortieHaut()
    signal sortieBas()

    implicitWidth: Mesures.colonnes * Mesures.celluleLargeur
    implicitHeight: Mesures.rangees * Mesures.celluleHauteur

    function allerPage(nouvelle: int): void {
        page = Math.max(0, Math.min(pages - 1, nouvelle));
    }

    function reinitialiser(): void {
        vue.currentIndex = vue.count > 0 ? 0 : -1;
        page = 0;
        defilement.stop();
        vue.contentY = vue.originY;
    }

    onPageChanged: {
        defilement.to = vue.originY + page * height;
        defilement.restart();
    }
    onPagesChanged: allerPage(page)

    NumberAnimation {
        id: defilement
        target: vue
        property: "contentY"
        duration: Kirigami.Units.longDuration
        easing.type: Easing.OutCubic
    }

    GridView {
        id: vue

        anchors.fill: parent
        clip: true
        cellWidth: Mesures.celluleLargeur
        cellHeight: Mesures.celluleHauteur
        // Défilement par pages seulement (molette et clavier)
        interactive: false
        focus: true
        activeFocusOnTab: true
        currentIndex: count > 0 ? 0 : -1
        pixelAligned: true
        // Les modèles changent sous la vue (comme dans Kickoff)
        reuseItems: false
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: false
        highlightFollowsCurrentItem: false
        Accessible.role: Accessible.Table
        Accessible.name: "Épinglé"

        // La dernière page est complétée, pour que chaque page commence à un
        // multiple de trois rangées
        footer: Item {
            width: 1
            height: grille.pages * grille.height - Math.ceil(vue.count / Mesures.colonnes) * Mesures.celluleHauteur
        }

        delegate: ElementEpingle {
            required property var model

            demarrer: grille.demarrer
            modele: vue.model
            nom: model.display ?? ""
            icone: model.decoration ?? null
            detail: model.description ?? ""
            favori: model.favoriteId ?? ""
            adresse: model.url ?? ""
            listeActions: model.actionList ?? null
            aActions: model.hasActionList ?? false
            selectionVisible: grille.selectionVisible
            Accessible.role: Accessible.Cell
        }

        move: transition
        moveDisplaced: transition

        Transition {
            id: transition
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                properties: "x, y"
                easing.type: Easing.OutCubic
            }
        }

        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                grille.allerPage(Math.floor(currentIndex / grille.parPage));
            }
        }

        Keys.onMenuPressed: event => {
            const element = currentItem as Element;
            if (element !== null) {
                element.ouvrirMenu(undefined, undefined);
            }
        }

        // Navigation au clavier de Kickoff (https://www.w3.org/TR/wai-aria-practices-1.2/#grid),
        // avec le passage d'une page à l'autre
        Keys.onPressed: event => {
            const colonnes = Mesures.colonnes;
            const aGauche = currentIndex % colonnes === (Application.layoutDirection === Qt.RightToLeft ? colonnes - 1 : 0);
            const aDroite = currentIndex % colonnes === (Application.layoutDirection === Qt.RightToLeft ? 0 : colonnes - 1);
            const enHaut = currentIndex < colonnes;
            const enBas = currentIndex >= count - ((count % colonnes) || colonnes);
            const ctrlMaj = (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier);
            if (grille.demarrer) {
                grille.demarrer.clavier = true;
            }
            // Entrée ou Espace : lancer
            if (count > 0 && [Qt.Key_Return, Qt.Key_Enter, Qt.Key_Space].includes(event.key)) {
                (currentItem as Element)?.lancer();
                event.accepted = true;
                return;
            }
            if (ctrlMaj && grille.demarrer && grille.demarrer.modifiable) {
                let cible = -1;
                switch (event.key) {
                case Qt.Key_Left: cible = aGauche ? -1 : currentIndex - 1; break;
                case Qt.Key_Right: cible = aDroite ? -1 : currentIndex + 1; break;
                case Qt.Key_Up: cible = currentIndex - colonnes; break;
                case Qt.Key_Down: cible = currentIndex + colonnes; break;
                }
                if (cible >= 0 && cible < count) {
                    model.moveRow(currentIndex, cible);
                    currentIndex = cible;
                    event.accepted = true;
                }
                return;
            }
            switch (event.key) {
            case Qt.Key_Left:
                if (!aGauche) {
                    moveCurrentIndexLeft();
                    event.accepted = true;
                }
                break;
            case Qt.Key_Right:
                if (!aDroite && currentIndex < count - 1) {
                    moveCurrentIndexRight();
                    event.accepted = true;
                }
                break;
            case Qt.Key_Up:
                if (enHaut) {
                    grille.sortieHaut();
                } else {
                    moveCurrentIndexUp();
                }
                event.accepted = true;
                break;
            case Qt.Key_Down:
                if (enBas) {
                    grille.sortieBas();
                } else {
                    currentIndex = Math.min(currentIndex + colonnes, count - 1);
                }
                event.accepted = true;
                break;
            case Qt.Key_Home:
                currentIndex = 0;
                event.accepted = true;
                break;
            case Qt.Key_End:
                currentIndex = count - 1;
                event.accepted = true;
                break;
            case Qt.Key_PageUp:
                if (grille.page > 0) {
                    currentIndex = (grille.page - 1) * grille.parPage;
                    event.accepted = true;
                }
                break;
            case Qt.Key_PageDown:
                if (grille.page < grille.pages - 1) {
                    currentIndex = (grille.page + 1) * grille.parPage;
                    event.accepted = true;
                }
                break;
            }
        }
    }

    // Une page par cran de molette ; un pavé tactile envoie de petits pas,
    // additionnés jusqu'à un cran (120)
    WheelHandler {
        id: molette
        property real cumul: 0
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            cumul += event.angleDelta.y;
            if (Math.abs(cumul) >= 120) {
                grille.allerPage(grille.page + (cumul < 0 ? 1 : -1));
                cumul = 0;
            }
        }
    }

    // Glisser une épingle à une autre place ; déposer un fichier ou une
    // application venue d'ailleurs l'épingle (KickoffDropArea.qml)
    DropArea {
        id: depot
        anchors.fill: parent
        enabled: grille.demarrer !== null && grille.demarrer.modifiable
        // Déplacements faits pendant le glisser, défaits si l'on sort de la
        // grille sans déposer
        property var deplacements: []

        onEntered: deplacements = []
        onPositionChanged: glisse => {
            const source = grille.demarrer.sourceGlisser.sourceItem as Element;
            if (glisse.source !== grille.demarrer.sourceGlisser || source === null) {
                return;
            }
            if (source.vue === vue && !transition.running) {
                const position = mapToItem(vue.contentItem, glisse.x, glisse.y);
                const cible = vue.indexAt(position.x, position.y);
                if (cible >= 0 && cible !== source.index) {
                    deplacements.push([source.index, cible]);
                    vue.model.moveRow(source.index, cible);
                    vue.currentIndex = source.index;
                }
            }
            glisse.accept(Qt.MoveAction);
        }
        onDropped: glisse => {
            if ((glisse.source !== grille.demarrer.sourceGlisser || grille.demarrer.sourceGlisser.sourceItem === null)
                && glisse.hasUrls) {
                const position = mapToItem(vue.contentItem, glisse.x, glisse.y);
                let cible = vue.indexAt(position.x, position.y);
                for (const adresse of glisse.urls) {
                    if (cible >= 0) {
                        vue.model.addFavoriteTo(adresse, ":current", cible++);
                    } else {
                        vue.model.addFavoriteTo(adresse, ":current");
                    }
                }
            }
            deplacements = [];
        }
        onExited: {
            while (deplacements.length > 0) {
                const [depart, arrivee] = deplacements.pop();
                vue.model.moveRow(arrivee, depart);
            }
        }
    }

    // Points des pages, à droite du volet (à 15 px de son bord, Mesures.qml)
    Column {
        x: grille.width + Mesures.bordGrille - Mesures.pointsBord - Mesures.pointTaille
        anchors.verticalCenter: parent.verticalCenter
        spacing: Mesures.pointEcart
        visible: grille.pages > 1

        Repeater {
            model: grille.pages

            delegate: Rectangle {
                id: point
                required property int index
                width: Mesures.pointTaille
                height: Mesures.pointTaille
                radius: width / 2
                color: Kirigami.Theme.textColor
                opacity: index === grille.page ? 1 : 0.4

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -Mesures.pointEcart / 2
                    onClicked: grille.allerPage(point.index)
                }
            }
        }
    }
}
