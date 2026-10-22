/*
    SPDX-FileCopyrightText: 2015 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2016 Anthony Fieroni <bvbfan@abv.bg>
    SPDX-FileCopyrightText: 2018 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// « Afficher le bureau » d'Ankh (D-052, lot 4) : la fine bande au bout de la
// barre des tâches de Windows 11. Le bouton de Plasma
// (applets/showdesktop de plasma-desktop 6.7) a une largeur fixe de 32 px ;
// celui-ci en fait 8, sur toute la hauteur de la barre. Un clic réduit
// toutes les fenêtres du bureau et de l'activité en cours ; un second clic
// rend celles qu'il a réduites. La logique est celle de
// MinimizeAllController.qml de Plasma, avec le module public
// org.kde.taskmanager.

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: racine

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    // Largeur de la bande de Windows 11 (À VALIDER sur des captures)
    readonly property int epaisseur: 8

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.hasConfigurationInterface: false

    Layout.minimumWidth: vertical ? -1 : epaisseur
    Layout.maximumWidth: vertical ? -1 : epaisseur
    Layout.preferredWidth: vertical ? -1 : epaisseur
    Layout.minimumHeight: vertical ? epaisseur : -1
    Layout.maximumHeight: vertical ? epaisseur : -1
    Layout.preferredHeight: vertical ? epaisseur : -1
    Layout.fillHeight: !vertical
    Layout.fillWidth: vertical

    toolTipMainText: actif ? "Restaurer les fenêtres" : "Afficher le bureau"
    toolTipSubText: actif ? "Rend les fenêtres réduites par ce bouton" : "Réduit toutes les fenêtres pour montrer le bureau"

    readonly property bool actif: Boolean(actifParBureau[bureauActivite])

    TaskManager.VirtualDesktopInfo {
        id: bureaux
    }

    TaskManager.ActivityInfo {
        id: activites
    }

    TaskManager.TasksModel {
        id: taches
        sortMode: TaskManager.TasksModel.SortLastActivated
        groupMode: TaskManager.TasksModel.GroupDisabled
    }

    readonly property string bureauActivite: activites.currentActivity + "_" + bureaux.currentDesktop
    property var actifParBureau: ({})
    // Fenêtres réduites par ce bouton, par bureau et activité
    property var reduites: ({})

    // Une fenêtre activée entre-temps annule le second clic, comme dans Plasma
    Connections {
        target: taches
        enabled: racine.actif

        function onActiveTaskChanged() {
            const cle = taches.data(taches.activeTask, TaskManager.AbstractTasksModel.Activities) + "_"
                + taches.data(taches.activeTask, TaskManager.AbstractTasksModel.VirtualDesktops);
            if (taches.activeTask.valid) {
                racine.actifParBureau[cle] = false;
                racine.actifParBureauChanged();
                racine.reduites[cle] = [];
            }
        }
    }

    function reduire() {
        const liste = [];
        for (let i = taches.count - 1; i >= 0; i--) {
            const idx = taches.makeModelIndex(i);
            const activitesTache = taches.data(idx, TaskManager.AbstractTasksModel.Activities);
            const bureauxTache = taches.data(idx, TaskManager.AbstractTasksModel.VirtualDesktops);
            if (!taches.data(idx, TaskManager.AbstractTasksModel.IsHidden)
                && (activitesTache.length === 0 || activitesTache.includes(activites.currentActivity))
                && (bureauxTache.length === 0 || bureauxTache[0] === -1 || bureauxTache.includes(bureaux.currentDesktop))) {
                taches.requestToggleMinimized(idx);
                liste.push(taches.makePersistentModelIndex(i));
            }
        }
        reduites[bureauActivite] = liste;
        actifParBureau[bureauActivite] = true;
        actifParBureauChanged();
    }

    function rendre() {
        actifParBureau[bureauActivite] = false;
        actifParBureauChanged();
        const liste = reduites[bureauActivite] || [];
        for (let i = 0; i < liste.length; i++) {
            const idx = liste[i];
            if (idx.valid && taches.data(idx, TaskManager.AbstractTasksModel.IsHidden)) {
                taches.requestToggleMinimized(idx);
            }
        }
        reduites[bureauActivite] = [];
    }

    Plasmoid.onActivated: actif ? rendre() : reduire()

    fullRepresentation: MouseArea {
        id: zone
        hoverEnabled: true
        activeFocusOnTab: true
        onClicked: Plasmoid.activated()
        Keys.onPressed: event => {
            if ([Qt.Key_Space, Qt.Key_Enter, Qt.Key_Return, Qt.Key_Select].includes(event.key)) {
                Plasmoid.activated();
            }
        }
        Accessible.name: racine.toolTipMainText
        Accessible.role: Accessible.Button
        Accessible.onPressAction: Plasmoid.activated()

        // Un fichier glissé sur la bande montre le bureau, comme dans Plasma
        DropArea {
            anchors.fill: parent
            onEntered: minuterie.start()
            onExited: minuterie.stop()
        }
        Timer {
            id: minuterie
            interval: 250
            onTriggered: Plasmoid.activated()
        }

        // Survol : la bande s'éclaircit
        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.textColor
            opacity: zone.containsPress ? 0.04 : (zone.containsMouse ? 0.08 : 0)
        }
        // Trait de séparation, de 16 px, sur le bord intérieur de la bande
        Rectangle {
            width: racine.vertical ? 16 : 1
            height: racine.vertical ? 1 : 16
            anchors.left: racine.vertical ? undefined : parent.left
            anchors.top: racine.vertical ? parent.top : undefined
            anchors.verticalCenter: racine.vertical ? undefined : parent.verticalCenter
            anchors.horizontalCenter: racine.vertical ? parent.horizontalCenter : undefined
            color: Kirigami.Theme.textColor
            opacity: 0.35
        }
    }
}
