/*
    SPDX-FileCopyrightText: 2013 Aurélien Gâteau <agateau@kde.org>
    SPDX-FileCopyrightText: 2014-2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2024 ivan tkachenko <me@ratijas.tk>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound
pragma Singleton

// Menu contextuel des éléments du Démarrer d'Ankh (clic droit, touche Menu),
// repris de Kickoff (applets/kickoff/ActionMenu.qml de plasma-desktop 6.7.5).
// Un seul menu est ouvert à la fois : il est partagé (singleton déclaré dans
// qmldir). Ses actions viennent du modèle (rôle actionList de Kicker) et de
// code/tools.js (épingles).

import QtQuick

import org.kde.plasma.extras as PlasmaExtras

import "code/tools.js" as Tools

Item {
    id: root

    property var actionList: null
    // Le modèle et la ligne de l'élément, qui reçoivent l'action choisie
    property QtObject modele: null
    property int ligne: -1
    // Le volet (Demarrer.qml), refermé quand l'action le demande ; Item, car
    // il contient lui-même les éléments qui ouvrent ce menu
    property Item demarrer: null

    // Menu de Qt (QMenu), dessiné par le style d'Ankh (lot 3)
    readonly property PlasmaExtras.Menu menu: PlasmaExtras.Menu {
        id: menu

        visualParent: null
        placement: PlasmaExtras.Menu.BottomPosedLeftAlignedPopup
    }

    visible: false

    Instantiator {
        active: root.actionList !== null
        model: root.actionList
        delegate: menuItemComponent
        onObjectAdded: (index, object) => menu.addMenuItem(object)
        onObjectRemoved: (index, object) => menu.removeMenuItem(object)
    }

    Component {
        id: menuComponent

        PlasmaExtras.Menu {}
    }

    Component {
        id: menuItemComponent

        PlasmaExtras.MenuItem {
            id: menuItem

            required property var modelData
            readonly property PlasmaExtras.Menu subMenu: modelData.subActions
                ? menuComponent.createObject(this, { visualParent: action }) as PlasmaExtras.Menu
                : null

            text: modelData.text ?? ""
            enabled: modelData.type !== "title" && (modelData.enabled ?? true)
            separator: modelData.type === "separator"
            section: modelData.type === "title"
            icon: modelData.icon ?? null
            checkable: modelData.checkable ?? false
            checked: modelData.checked ?? false

            readonly property Instantiator __instantiator: Instantiator {
                active: menuItem.subMenu !== null
                model: menuItem.modelData.subActions
                delegate: menuItemComponent
                onObjectAdded: (index, object) => menuItem.subMenu.addMenuItem(object)
                onObjectRemoved: (index, object) => menuItem.subMenu.removeMenuItem(object)
            }

            onClicked: {
                const fermer = Tools.triggerAction(root.modele, root.ligne,
                    modelData.actionId, modelData.actionArgument);
                if (fermer && root.demarrer) {
                    root.demarrer.fermerApresLancement();
                }
            }
        }
    }

    // Ouvre le menu de l'élément, à la place du pointeur (x, y) ou sous lui
    function ouvrir(element: Item, actions: var, modeleElement: QtObject, ligneElement: int,
                    demarrerElement: Item, x: var, y: var): void {
        modele = modeleElement;
        ligne = ligneElement;
        demarrer = demarrerElement;
        menu.visualParent = element;
        actionList = actions;
        if (x !== undefined && y !== undefined) {
            menu.open(x, y);
        } else {
            menu.openRelative();
        }
    }
}
