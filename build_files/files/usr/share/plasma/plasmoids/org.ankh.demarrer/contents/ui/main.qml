/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Démarrer d'Ankh (D-052, lot 5) : le Démarrer « classique » de Windows 11
// (mon choix du 2026-10-22), dérivé de Kickoff (applets/kickoff de
// plasma-desktop 6.7.5, commit 66c0d62). Paquet QML pur : Kickoff n'a aucun
// code C++ propre (plasma_add_applet … GENERATE_APPLET_CLASS) ; ses
// singletons sont déclarés dans qmldir, sa configuration est
// contents/config/main.xml. « X-Plasma-Provides: org.kde.plasma.launchermenu »
// (metadata.json) fait ouvrir ce menu par la touche Méta et par
// activateLauncherMenu (shellcorona.cpp de plasma-workspace).
//
// Ce fichier relie Plasma au volet : bouton de la barre, modèles de Kicker,
// taille du volet. Le volet lui-même (Demarrer.qml) ne dépend pas de Plasmoid.

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: racine

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    readonly property Modeles modeles: Modeles {
        applet: racine
        // Sans tiret avant le numéro (Modeles.qml)
        idClient: "org.ankh.demarrer.favorites.instance-" + Plasmoid.id
        triAlphabetique: Plasmoid.configuration.alphaSort
        aReprendre: !Plasmoid.configuration.favoritesPortedToKAstats
        anciensFavoris: Plasmoid.configuration.favorites
        onFavorisRepris: Plasmoid.configuration.favoritesPortedToKAstats = true
    }

    // Marges du cadre des volets (style Plasma d'Ankh : 4 de chaque côté).
    // La fenêtre du volet mesure le contenu plus ces marges
    // (PlasmaWindow::padding, fixedMargins de dialogs/background, libplasma
    // 6.7.5).
    readonly property KSvg.FrameSvgItem cadre: KSvg.FrameSvgItem {
        visible: false
        imagePath: "dialogs/background"
    }
    // La coque ajoute 1 px au contenu du côté de la barre, pour un trait
    // qu'elle ne dessine pas quand le volet flotte (appletParent.extraHeight
    // et extraWidth de CompactApplet.qml, plasma-desktop 6.7.5)
    readonly property int extraLargeur: [PlasmaCore.Types.LeftEdge, PlasmaCore.Types.RightEdge].includes(Plasmoid.location) ? 1 : 0
    readonly property int extraHauteur: [PlasmaCore.Types.TopEdge, PlasmaCore.Types.BottomEdge].includes(Plasmoid.location) ? 1 : 0
    // Taille demandée pour que le volet visible mesure 640 × 726
    readonly property int largeurContenu: Mesures.largeurVolet - cadre.fixedMargins.left - cadre.fixedMargins.right - extraLargeur
    readonly property int hauteurContenu: Mesures.hauteurVolet - cadre.fixedMargins.top - cadre.fixedMargins.bottom - extraHauteur

    Plasmoid.icon: Plasmoid.configuration.icon
    toolTipSubText: ""
    hideOnWindowDeactivate: !Plasmoid.configuration.pin
    preferredRepresentation: compactRepresentation

    fullRepresentation: Demarrer {
        focus: true
        modeles: racine.modeles
        ouvert: racine.expanded
        modifiable: Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
        garderOuvert: Plasmoid.configuration.pin
        margeGauche: racine.cadre.fixedMargins.left
        margeHaut: racine.cadre.fixedMargins.top
        margeDroite: racine.cadre.fixedMargins.right
        margeBas: racine.cadre.fixedMargins.bottom
        // Taille fixe, comme dans Windows 11 : pas de poignée
        Layout.minimumWidth: racine.largeurContenu
        Layout.preferredWidth: racine.largeurContenu
        Layout.maximumWidth: racine.largeurContenu
        Layout.minimumHeight: racine.hauteurContenu
        Layout.preferredHeight: racine.hauteurContenu
        Layout.maximumHeight: racine.hauteurContenu
        onFermer: racine.expanded = false
    }

    // Le bouton prend toute l'épaisseur de la barre, sans ses marges, comme
    // les boutons de la barre des tâches (constraintHints d'applets/taskmanager)
    Plasmoid.constraintHints: Plasmoid.CanFillArea

    // Bouton Démarrer de la barre, dessiné comme les boutons des applications
    // (lot 4, style Plasma d'Ankh, widgets/tasks) : bouton de 56 × 48 (la
    // barre plus les marges de côté du dessin, preferredMaxWidth de
    // code/LayoutMetrics.js d'applets/taskmanager), logo de 32 placé comme
    // leurs icônes (haut à 7), et le même rectangle de 48 × 44 aux coins de 4
    // (préfixe « hover » : le rectangle seul, sans trait d'accent) au survol
    // et quand le volet est ouvert. Il s'ouvre aussi quand on y glisse un
    // fichier, comme celui de Kickoff.
    compactRepresentation: MouseArea {
        id: bouton

        property bool etaitOuvert: false

        Layout.minimumWidth: racine.vertical ? -1 : height + cadreBouton.margins.left + cadreBouton.margins.right
        Layout.preferredWidth: Layout.minimumWidth
        Layout.maximumWidth: Layout.minimumWidth
        Layout.minimumHeight: racine.vertical ? width + cadreBouton.margins.top + cadreBouton.margins.bottom : -1
        Layout.preferredHeight: Layout.minimumHeight
        Layout.maximumHeight: Layout.minimumHeight
        hoverEnabled: true
        Accessible.name: Plasmoid.title
        Accessible.role: Accessible.Button

        onPressed: etaitOuvert = racine.expanded
        onClicked: racine.expanded = !etaitOuvert

        DropArea {
            id: depot
            anchors.fill: parent
            onEntered: glisse => {
                if (glisse.hasUrls) {
                    minuterie.start();
                }
            }
            onExited: minuterie.stop()
        }
        Timer {
            id: minuterie
            interval: 250
            onTriggered: racine.expanded = true
        }

        // Toujours là pour ses marges, visible seulement au survol et volet
        // ouvert ; un peu plus clair à l'appui
        KSvg.FrameSvgItem {
            id: cadreBouton
            anchors.fill: parent
            imagePath: "widgets/tasks"
            prefix: "hover"
            opacity: bouton.containsMouse || depot.containsDrag || racine.expanded ? (bouton.pressed ? 0.67 : 1) : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
        // Logo de la taille des icônes des applications : la barre moins les
        // marges du haut et du bas du dessin (iconBox de Task.qml)
        Kirigami.Icon {
            readonly property real taille: racine.vertical
                ? bouton.width - cadreBouton.margins.left - cadreBouton.margins.right
                : bouton.height - cadreBouton.margins.top - cadreBouton.margins.bottom
            x: racine.vertical ? cadreBouton.margins.left : Math.round((bouton.width - taille) / 2)
            y: racine.vertical ? Math.round((bouton.height - taille) / 2) : cadreBouton.margins.top
            width: taille
            height: taille
            source: Plasmoid.icon
            active: bouton.containsMouse || depot.containsDrag
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Modifier les applications…"
            icon.name: "kmenuedit"
            visible: Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
            onTriggered: racine.modeles.modifierApplications()
        }
    ]

    Component.onCompleted: {
        // Méta et activateLauncherMenu ouvrent et ferment le volet
        Plasmoid.activationTogglesExpanded = true;
    }
}
