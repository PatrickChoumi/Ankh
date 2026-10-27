/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Bouton « Vue des tâches » de la barre d'Ankh (D-052, lot 7b ; mon choix du
// 2026-10-23) : comme dans Windows 11, à droite du Démarrer, il ouvre la vue
// des tâches d'Ankh (effet org.ankh.vuetaches de KWin). Ankh garde tous les
// raccourcis de KDE : la vue n'a pas de touche à elle ; le bouton l'appelle
// par son nom dans kglobalaccel (invokeShortcut, composant « kwin », action
// AnkhVueTaches du ShortcutHandler de l'effet), par le module D-Bus de Plasma
// (org.kde.plasma.workspace.dbus, components/dbus de plasma-workspace 6.7).
//
// Dessiné comme le Démarrer et les boutons des applications (lot 4, style
// Plasma d'Ankh, widgets/tasks) : bouton de la hauteur de la barre plus les
// marges de côté du dessin, rectangle de 48 × 44 aux coins de 4 au survol.
// Le symbole, deux fenêtres l'une devant l'autre, suit celui de Windows 11
// (observé, À VALIDER) en 24 px dans la place des icônes (32).

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.dbus as DBus

PlasmoidItem {
    id: racine

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // Ouvre ou ferme la vue des tâches (l'action de l'effet bascule)
    function basculerVue(): void {
        DBus.SessionBus.asyncCall({
            "service": "org.kde.kglobalaccel",
            "path": "/component/kwin",
            "iface": "org.kde.kglobalaccel.Component",
            "member": "invokeShortcut",
            "arguments": [new DBus.string("AnkhVueTaches")]
        });
    }

    Plasmoid.icon: "window-duplicate"
    Plasmoid.title: "Vue des tâches"
    Plasmoid.status: PlasmaCore.Types.ActiveStatus
    Plasmoid.hasConfigurationInterface: false
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.constraintHints: Plasmoid.CanFillArea
    // Sans volet, Plasma montre toujours le contenu de la racine
    // (appletShouldBeExpanded, src/plasmaquick/appletquickitem.cpp de
    // libplasma 6.7) : une représentation compacte n'y serait jamais créée,
    // et le bouton resterait vide (vu en VM, run 40014608085). Comme la bande
    // « Afficher le bureau » (org.ankh.bureau), le bouton est donc la racine.
    preferredRepresentation: fullRepresentation

    // La hauteur de la barre plus les marges de côté du dessin, comme le
    // Démarrer et les boutons des applications
    Layout.minimumWidth: vertical ? -1 : height + cadreBouton.margins.left + cadreBouton.margins.right
    Layout.preferredWidth: Layout.minimumWidth
    Layout.maximumWidth: Layout.minimumWidth
    Layout.minimumHeight: vertical ? width + cadreBouton.margins.top + cadreBouton.margins.bottom : -1
    Layout.preferredHeight: Layout.minimumHeight
    Layout.maximumHeight: Layout.minimumHeight
    Layout.fillHeight: !vertical
    Layout.fillWidth: vertical

    toolTipMainText: "Vue des tâches"
    toolTipSubText: ""

    // Un raccourci posé sur l'applet (réglages de KDE) l'appelle aussi
    Connections {
        target: Plasmoid
        function onActivated(): void {
            racine.basculerVue();
        }
    }

    MouseArea {
        id: bouton

        anchors.fill: parent
        hoverEnabled: true
        Accessible.name: Plasmoid.title
        Accessible.role: Accessible.Button

        onClicked: racine.basculerVue()

        // Toujours là pour ses marges, visible seulement au survol ; un peu
        // plus clair à l'appui
        KSvg.FrameSvgItem {
            id: cadreBouton
            anchors.fill: parent
            imagePath: "widgets/tasks"
            prefix: "hover"
            opacity: bouton.containsMouse ? (bouton.pressed ? 0.67 : 1) : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Place des icônes des applications (la barre moins les marges du
        // haut et du bas du dessin, iconBox de Task.qml), symbole de 24 au
        // centre : la fenêtre de derrière en contour, celle de devant pleine
        Item {
            id: place
            readonly property real taille: racine.vertical
                ? bouton.width - cadreBouton.margins.left - cadreBouton.margins.right
                : bouton.height - cadreBouton.margins.top - cadreBouton.margins.bottom
            x: racine.vertical ? cadreBouton.margins.left : Math.round((bouton.width - taille) / 2)
            y: racine.vertical ? Math.round((bouton.height - taille) / 2) : cadreBouton.margins.top
            width: taille
            height: taille

            Item {
                anchors.centerIn: parent
                width: 24
                height: 24

                Rectangle {
                    x: 8
                    y: 2
                    width: 14
                    height: 14
                    radius: 3
                    color: "transparent"
                    border.width: 1.5
                    border.color: Kirigami.Theme.textColor
                }
                // Le fond de la fenêtre de devant cache la ligne de derrière
                Rectangle {
                    x: 2
                    y: 8
                    width: 14
                    height: 14
                    radius: 3
                    color: Kirigami.Theme.textColor
                    border.width: 1.5
                    border.color: Kirigami.Theme.backgroundColor
                }
            }
        }
    }
}
