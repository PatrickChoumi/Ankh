/*
    SPDX-FileCopyrightText: 2026 Ankh
    SPDX-FileCopyrightText: Ne pas déranger et historique d'après applets/notifications de plasma-workspace 6.7.5 (KDE)

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

// Horloge d'Ankh (D-052, lot 6b ; mon choix du 2026-10-22) : dans la barre,
// l'heure, la date et une cloche, comme Windows 11 ; un clic ou Windows+N
// ouvre un seul volet, avec les notifications en haut et le calendrier en
// bas. Elle remplace l'horloge de Plasma dans la barre d'Ankh
// (build_files/plasma/ankh-barre.js) ; l'applet des notifications de Plasma
// reste chargée, cachée : c'est elle qui affiche les bulles.

import QtQuick
import QtQuick.Layouts

import org.kde.ksvg as KSvg
import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: racine

    Plasmoid.constraintHints: Plasmoid.CanFillArea
    Plasmoid.status: PlasmaCore.Types.ActiveStatus
    Plasmoid.hasConfigurationInterface: false
    preferredRepresentation: compactRepresentation

    // L'heure, à la minute près : vérifiée chaque seconde, changée seulement
    // quand la minute ou le jour change
    property date maintenant: new Date()

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            const d = new Date();
            if (d.getMinutes() !== racine.maintenant.getMinutes() || d.getDate() !== racine.maintenant.getDate()) {
                racine.maintenant = d;
            }
        }
    }

    // Noms des jours et des mois dans la langue du système (Qt.formatDate
    // les donne en anglais depuis Qt 6)
    toolTipMainText: {
        const texte = racine.maintenant.toLocaleDateString(Qt.locale(), "dddd d MMMM yyyy");
        return texte.charAt(0).toUpperCase() + texte.slice(1);
    }
    toolTipSubText: ""

    // Ne pas déranger, comme l'applet des notifications de Plasma
    // (applets/notifications/global/Globals.qml) : jusqu'à nouvel ordre
    // (date lointaine), ou fin de toutes les suspensions
    NotificationManager.Settings {
        id: reglages
        live: true
    }

    readonly property bool nePasDeranger: {
        const jusqua = reglages.notificationsInhibitedUntil;
        return (jusqua && !isNaN(jusqua.getTime()) && Date.now() < jusqua.getTime())
            || reglages.notificationsInhibitedByApplication;
    }

    function basculerNePasDeranger(): void {
        if (nePasDeranger) {
            reglages.notificationsInhibitedUntil = undefined;
            reglages.revokeApplicationInhibitions();
        } else {
            const loin = new Date();
            loin.setFullYear(loin.getFullYear() + 1);
            reglages.notificationsInhibitedUntil = loin;
        }
        reglages.save();
    }

    KSvg.FrameSvgItem {
        id: cadre
        visible: false
        imagePath: "dialogs/background"
    }

    // Un clic sur l'heure, volet ouvert, le ferme : l'état est lu à l'appui,
    // car le volet se ferme déjà en perdant le focus, avant le clic
    compactRepresentation: Horloge {
        property bool etaitOuvert: false
        ouvert: racine.expanded
        maintenant: racine.maintenant
        nePasDeranger: racine.nePasDeranger
        onPressed: etaitOuvert = racine.expanded
        onClicked: racine.expanded = !etaitOuvert
    }

    fullRepresentation: Centre {
        id: centre
        margeGauche: cadre.fixedMargins.left
        margeHaut: cadre.fixedMargins.top
        margeDroite: cadre.fixedMargins.right
        margeBas: cadre.fixedMargins.bottom
        nePasDeranger: racine.nePasDeranger
        onBasculerNePasDeranger: racine.basculerNePasDeranger()
        // Taille fixe, comme le Démarrer : lue sur width et height, elle suivait
        // celle que Plasma impose au volet (vu en VM : volet de 568 × 12)
        Layout.minimumWidth: centre.largeurContenu
        Layout.maximumWidth: centre.largeurContenu
        Layout.preferredWidth: centre.largeurContenu
        Layout.minimumHeight: centre.hauteurContenu
        Layout.maximumHeight: centre.hauteurContenu
        Layout.preferredHeight: centre.hauteurContenu

        // À chaque ouverture, le calendrier revient au mois du jour
        Connections {
            target: racine
            function onExpandedChanged(): void {
                if (racine.expanded) {
                    centre.revenirAujourdhui();
                }
            }
        }
    }
}
