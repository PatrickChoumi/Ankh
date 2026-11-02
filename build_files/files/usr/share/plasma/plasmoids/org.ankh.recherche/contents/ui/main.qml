/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Bouton « Rechercher » de la barre d'Ankh (D-052, lot 10h) : comme dans
// Windows 11, entre le Démarrer et la vue des tâches, il ouvre la recherche.
// Le Démarrer d'Ankh a la sienne, son champ prêt à la saisie dès qu'il
// s'ouvre : le bouton l'ouvre par la méthode de plasmashell qui ouvre le
// lanceur de la barre (activateLauncherMenu, org.kde.PlasmaShell,
// shell/shellcorona.cpp de plasma-workspace 6.7 : l'applet qui fournit
// org.kde.plasma.launchermenu, le Démarrer d'Ankh). Un second clic le ferme.
//
// Dessiné comme le bouton « Vue des tâches » (lot 7b) : bouton de la hauteur
// de la barre plus les marges de côté du dessin, rectangle de 48 × 44 aux
// coins de 4 au survol ; symbole de 24, une loupe, comme celle de Windows 11
// (observée, À VALIDER).

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

    // Ouvre (ou ferme) le Démarrer d'Ankh, champ de recherche prêt
    function ouvrirRecherche(): void {
        DBus.SessionBus.asyncCall({
            "service": "org.kde.plasmashell",
            "path": "/PlasmaShell",
            "iface": "org.kde.PlasmaShell",
            "member": "activateLauncherMenu",
            "arguments": []
        });
    }

    Plasmoid.icon: "search"
    Plasmoid.title: "Rechercher"
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

    toolTipMainText: "Rechercher"
    toolTipSubText: ""

    // Un raccourci posé sur l'applet (réglages de KDE) l'appelle aussi
    Connections {
        target: Plasmoid
        function onActivated(): void {
            racine.ouvrirRecherche();
        }
    }

    MouseArea {
        id: bouton

        anchors.fill: parent
        hoverEnabled: true
        Accessible.name: Plasmoid.title
        Accessible.role: Accessible.Button

        onClicked: racine.ouvrirRecherche()

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
        // centre : une loupe
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

                // Loupe : un cercle et son manche, à 45°
                Rectangle {
                    x: 3
                    y: 3
                    width: 13
                    height: 13
                    radius: width / 2
                    color: "transparent"
                    border.width: 1.5
                    border.color: Kirigami.Theme.textColor
                }
                Rectangle {
                    x: 14.5
                    y: 17
                    width: 7
                    height: 1.5
                    radius: 0.75
                    rotation: 45
                    color: Kirigami.Theme.textColor
                }
            }
        }
    }
}
