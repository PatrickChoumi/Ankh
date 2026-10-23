/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Paramètres rapides d'Ankh (D-052, lot 6a ; mes choix du 2026-10-22) : un
// seul bouton dans la barre (réseau, son, batterie), qui ouvre un seul
// volet : lecteur multimédia, tuiles (Wi-Fi, Bluetooth, mode avion,
// économie d'énergie, éclairage nocturne, Ne pas déranger, mode sombre),
// luminosité et volume, batterie et réglages. Il remplace les applets
// réseau, son, Bluetooth, batterie, luminosité et lecteur de la zone de
// notification (build_files/plasma/ankh-barre.js). Les touches de volume et
// de luminosité restent gérées par les services de Plasma (kded de
// plasma-pa, powerdevil), pas par ces applets.

import QtQuick
import QtQuick.Layouts

import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: racine

    // Toute la hauteur de la barre, comme les boutons des applications
    Plasmoid.constraintHints: Plasmoid.CanFillArea
    Plasmoid.icon: etat.iconeReseau
    Plasmoid.status: PlasmaCore.Types.ActiveStatus
    Plasmoid.hasConfigurationInterface: false
    preferredRepresentation: compactRepresentation

    toolTipMainText: "Paramètres rapides"
    toolTipSubText: (etat.wifiDisponible ? (etat.wifiActif ? "Wi-Fi activé" : "Wi-Fi désactivé") + "\n" : "")
        + (etat.sonDisponible ? (etat.muet ? "Son coupé" : "Volume : " + etat.volume + " %") : "")
        + (etat.batterieDisponible ? "\nBatterie : " + etat.batteriePourcent + " %" : "")

    Etat {
        id: etat
    }

    // Marges du cadre des volets du style Plasma (dialogs/background) : le
    // volet visible garde les mesures de Windows 11
    KSvg.FrameSvgItem {
        id: cadre
        visible: false
        imagePath: "dialogs/background"
    }

    // Un clic sur le bouton, volet ouvert, le ferme : le volet se ferme déjà
    // en perdant le focus, avant le clic ; l'état est donc lu à l'appui, comme
    // dans le Démarrer et les applets de Plasma
    compactRepresentation: Bouton {
        property bool etaitOuvert: false
        etat: etat
        ouvert: racine.expanded
        onPressed: etaitOuvert = racine.expanded
        onClicked: racine.expanded = !etaitOuvert
    }

    fullRepresentation: Volet {
        id: volet
        etat: etat
        margeGauche: cadre.fixedMargins.left
        margeHaut: cadre.fixedMargins.top
        margeDroite: cadre.fixedMargins.right
        margeBas: cadre.fixedMargins.bottom
        Layout.minimumWidth: width
        Layout.maximumWidth: width
        Layout.preferredWidth: width
        Layout.minimumHeight: height
        Layout.maximumHeight: height
        Layout.preferredHeight: height

        // Le volet revient à l'accueil à chaque ouverture
        Connections {
            target: racine
            function onExpandedChanged(): void {
                if (!racine.expanded) {
                    volet.page = "accueil";
                }
            }
        }
    }
}
