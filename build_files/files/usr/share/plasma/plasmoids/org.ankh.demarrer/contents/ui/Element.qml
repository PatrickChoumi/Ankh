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

// Base des éléments du Démarrer d'Ankh (épingle, ligne de liste,
// recommandation), adaptée de AbstractKickoffItemDelegate.qml de Kickoff
// (plasma-desktop 6.7.5) : clic pour lancer, clic droit ou touche Menu pour
// le menu contextuel, glisser vers le bureau, la barre ou une autre place
// des épingles. Les données sont passées par la vue (rôles de Kicker), et
// non lues dans un modèle imposé : « Recommandé » mêle deux modèles.

import QtQuick
import QtQuick.Templates as T

import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

import "code/tools.js" as Tools

T.ItemDelegate {
    id: element

    required property int index
    // Le volet (Demarrer.qml) ; Item, car il contient lui-même ce type
    property Item demarrer: null
    // Modèle et ligne qui reçoivent le lancement et les actions
    property QtObject modele: null
    property int ligne: index
    // Rôles de Kicker (abstractmodel.cpp:17-38)
    property string nom: ""
    property var icone: null
    property string detail: ""
    property string favori: ""
    property url adresse: ""
    property var listeActions: null
    property bool aActions: false
    property bool nouvelle: false
    property bool separateur: false

    readonly property Flickable vue: ListView.view ?? GridView.view
    readonly property bool courant: (ListView.isCurrentItem || GridView.isCurrentItem) ?? false
    // La vue montre son élément courant (clavier, ou meilleur résultat de
    // la recherche quand le champ a le focus)
    property bool selectionVisible: false
    property bool retireEnGlissant: false
    property bool texteTronque: false

    // Élément dont l'image suit le pointeur quand on le glisse
    property Item imageGlissee: null
    readonly property bool glissementActif: glisser.active

    readonly property bool glissable: enabled && demarrer !== null && demarrer.modifiable
        && adresse.toString() !== ""

    down: zone.pressed || glisser.active
    hoverEnabled: false
    enabled: !separateur
    focusPolicy: Qt.NoFocus
    text: nom

    Accessible.role: Accessible.ListItem
    Accessible.name: nom
    Accessible.description: detail !== nom ? detail : ""
    Accessible.onPressAction: lancer()

    // L'élément au-dessus des autres pendant qu'on le glisse
    z: Drag.active ? 4 : 1

    function lancer(): void {
        if (vue) {
            vue.currentIndex = index;
        }
        if (demarrer) {
            demarrer.lancer(modele, ligne);
        }
    }

    // Menu contextuel : actions du modèle, puis « Épingler » ou « Détacher »,
    // insérées comme dans Kicker (fillActionMenu), avant « Ajouter à… »
    function ouvrirMenu(x: var, y: var): void {
        if (!demarrer || !(aActions || favori !== "")) {
            return;
        }
        let actions = listeActions ? Array.from(listeActions) : [];
        const modeleEpingles = modele && modele.favoritesModel ? modele.favoritesModel : null;
        const epingles = Tools.createFavoriteActions(modeleEpingles, favori);
        if (epingles) {
            if (actions.length > 0) {
                const premierAjout = actions.findIndex(action =>
                    ["addToDesktop", "addToTaskManager", "addToPanel"].includes(action?.actionId));
                if (premierAjout >= 0) {
                    actions.splice(premierAjout, 0, ...epingles);
                } else {
                    actions.push({ type: "separator" }, ...epingles);
                }
            } else {
                actions = epingles;
            }
        }
        if (actions.length > 0) {
            ActionMenu.ouvrir(element, actions, modele, ligne, demarrer, x, y);
        }
    }

    background: Survol {
        survole: zone.containsMouse && !element.separateur
        appuye: element.down
        selectionne: element.courant && element.selectionVisible
        anneau: element.courant && element.selectionVisible && (element.vue?.activeFocus ?? false)
            && (element.demarrer?.clavier ?? false)
    }

    // Glisser : vers le bureau, la barre des tâches, ou une autre place des
    // épingles (DropArea de GrilleEpingles)
    DragHandler {
        id: glisser
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
        enabled: element.glissable && element.imageGlissee !== null
        // Sans cible, la vue ne déplace pas l'élément (bogue 449426 de KDE)
        target: null
        onActiveChanged: element.demarrer.glisser(element, glisser.active)
    }

    MouseArea {
        id: zone
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.ArrowCursor

        onPressed: souris => {
            if (element.vue) {
                element.vue.currentIndex = element.index;
            }
            // Menu à l'appui, comme dans Qt Widgets
            if (souris.button === Qt.RightButton) {
                element.ouvrirMenu(souris.x, souris.y);
            }
        }
        onClicked: souris => {
            if (souris.button === Qt.LeftButton && !glisser.active) {
                element.lancer();
            }
        }

        TapHandler {
            acceptedDevices: PointerDevice.TouchScreen
            onLongPressed: element.ouvrirMenu(point.position.x, point.position.y)
        }
    }

    PC3.ToolTip.text: element.texteTronque ? element.nom : ""
    PC3.ToolTip.visible: zone.containsMouse && PC3.ToolTip.text.length > 0
    PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
}
