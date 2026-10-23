/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Volet des paramètres rapides d'Ankh (D-052, lot 6a ; mes choix du
// 2026-10-22). Mesures relevées sur l'image officielle de Microsoft
// (billet Windows Insider de la build 25967, à 150 %, recherche du lot 6),
// en pixels du volet visible, cadre compris :
// - largeur de 372 ;
// - tuiles de 96×48, trois par rangée, à 30 du bord gauche, espacées de 12,
//   une rangée tous les 96 (libellé compris), la première à 32 du haut ;
// - un trait de séparation 48 sous la dernière rangée de tuiles ;
// - curseurs : icône de 16 à 32 du bord, rail de 64 à 305, rangées de 40,
//   la première à 18 sous le trait ; bouton de la sortie son à droite ;
// - bande du bas de 40 : batterie et pourcentage à 16 du bord gauche,
//   bouton des réglages à 16 du bord droit.
// Au-dessus, le lecteur multimédia quand quelque chose joue (mon choix),
// dans une carte. Les tuiles sans matériel (Wi-Fi, Bluetooth…) sont
// retirées, comme sous Windows 11. Le contenu est placé dans le cadre du
// volet de Plasma, dont les marges (margeGauche…) sont déduites.

import QtQuick

import org.kde.kirigami as Kirigami
import org.ankh.commun

Item {
    id: volet

    required property var etat
    property int margeGauche: 4
    property int margeHaut: 4
    property int margeDroite: 4
    property int margeBas: 4

    // « accueil », « wifi », « bluetooth » ou « son »
    property string page: "accueil"

    readonly property int largeurVisible: 372
    readonly property int hauteurLecteur: etat.lecteurPresent ? 124 + 12 : 0

    // Tuiles présentes, dans l'ordre de Windows 11, puis le mode sombre
    readonly property var tuiles: {
        const liste = [];
        if (etat.wifiDisponible) liste.push("wifi");
        if (etat.btDisponible) liste.push("bluetooth");
        if (etat.avionDisponible) liste.push("avion");
        if (etat.economieDisponible) liste.push("economie");
        if (etat.nuitDisponible) liste.push("nuit");
        liste.push("nePasDeranger");
        liste.push("sombre");
        return liste;
    }
    readonly property int rangees: Math.ceil(tuiles.length / 3)
    readonly property int curseurs: (etat.luminositeDisponible ? 1 : 0) + (etat.sonDisponible ? 1 : 0)

    // Hauteurs, en pixels du volet visible
    readonly property int hautTuiles: 32
    readonly property int traitY: hautTuiles + rangees * 96
    readonly property int hautCurseurs: traitY + 1 + 18
    readonly property int piedY: hautCurseurs + curseurs * 40 + (curseurs > 0 ? 14 : 0)
    readonly property int hauteurVisible: hauteurLecteur + piedY + 40

    width: largeurVisible - margeGauche - margeDroite
    height: hauteurVisible - margeHaut - margeBas

    Couleurs {
        id: couleurs
    }

    function texte(nom: string): string {
        return {
            wifi: "Wi-Fi",
            bluetooth: "Bluetooth",
            avion: "Mode avion",
            economie: "Économie d'énergie",
            nuit: "Éclairage nocturne",
            nePasDeranger: "Ne pas déranger",
            sombre: "Mode sombre"
        }[nom];
    }

    function icone(nom: string): string {
        return {
            wifi: etat.wifiActif ? "network-wireless-symbolic" : "network-wireless-disconnected-symbolic",
            bluetooth: etat.btActif ? "network-bluetooth-symbolic" : "network-bluetooth-inactive-symbolic",
            avion: "network-flightmode-on",
            economie: "battery-profile-powersave-symbolic",
            nuit: "redshift-status-on",
            nePasDeranger: "notifications-disabled",
            sombre: "contrast"
        }[nom];
    }

    function active(nom: string): bool {
        return {
            wifi: etat.wifiActif,
            bluetooth: etat.btActif,
            avion: etat.avionActif,
            economie: etat.economieActive,
            nuit: etat.nuitActive,
            nePasDeranger: etat.nePasDeranger,
            sombre: etat.sombre
        }[nom];
    }

    function basculer(nom: string): void {
        switch (nom) {
        case "wifi": etat.basculerWifi(); break;
        case "bluetooth": etat.basculerBt(); break;
        case "avion": etat.basculerAvion(); break;
        case "economie": etat.basculerEconomie(); break;
        case "nuit": etat.basculerNuit(); break;
        case "nePasDeranger": etat.basculerNePasDeranger(); break;
        case "sombre": etat.basculerSombre(); break;
        }
    }

    // Tout est placé en pixels du volet visible : ce conteneur recule des
    // marges du cadre
    Item {
        id: zoneVisible
        x: -volet.margeGauche
        y: -volet.margeHaut
        width: volet.largeurVisible
        height: volet.hauteurVisible

        Lecteur {
            visible: volet.etat.lecteurPresent
            x: 12
            y: 12
            width: parent.width - 24
            etat: volet.etat
        }

        // Accueil : tuiles et curseurs
        Item {
            id: accueil
            visible: volet.page === "accueil"
            y: volet.hauteurLecteur
            width: parent.width
            height: volet.piedY

            Repeater {
                model: volet.tuiles
                delegate: Tuile {
                    required property string modelData
                    required property int index
                    x: 30 + (index % 3) * 108
                    y: volet.hautTuiles + Math.floor(index / 3) * 96
                    texte: volet.texte(modelData)
                    icone: volet.icone(modelData)
                    active: volet.active(modelData)
                    fleche: modelData === "wifi" || modelData === "bluetooth"
                    onBasculee: volet.basculer(modelData)
                    onOuverte: volet.page = modelData
                }
            }

            // Trait de séparation
            Rectangle {
                y: volet.traitY
                width: parent.width
                height: 1
                color: couleurs.separateur
            }

            Column {
                y: volet.hautCurseurs
                width: parent.width

                // Luminosité
                Item {
                    visible: volet.etat.luminositeDisponible
                    width: parent.width
                    height: 40
                    Kirigami.Icon {
                        x: 32
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16
                        source: "brightness-high"
                        isMask: true
                        color: Kirigami.Theme.textColor
                    }
                    Curseur {
                        x: 64 - 9
                        width: 305 - 64 + 18
                        anchors.verticalCenter: parent.verticalCenter
                        nom: "Luminosité"
                        valeur: volet.etat.luminositePourcent
                        onDeplace: valeur => volet.etat.reglerLuminosite(valeur)
                    }
                }

                // Volume
                Item {
                    visible: volet.etat.sonDisponible
                    width: parent.width
                    height: 40
                    BoutonDiscret {
                        x: 24
                        anchors.verticalCenter: parent.verticalCenter
                        icone: volet.etat.iconeSon
                        infobulle: volet.etat.muet ? "Rétablir le son" : "Couper le son"
                        onClique: volet.etat.basculerMuet()
                    }
                    Curseur {
                        x: 64 - 9
                        width: 305 - 64 + 18
                        anchors.verticalCenter: parent.verticalCenter
                        nom: "Volume"
                        actif: !volet.etat.muet
                        valeur: volet.etat.volume
                        onDeplace: valeur => volet.etat.regler(valeur)
                    }
                    // Icône à 317 et flèche à 338, comme sur l'image de Microsoft
                    BoutonDiscret {
                        x: 311
                        anchors.verticalCenter: parent.verticalCenter
                        icone: "audio-speakers-symbolic"
                        fleche: true
                        infobulle: "Choisir la sortie son"
                        onClique: volet.page = "son"
                    }
                }
            }
        }

        // Pages de liste, à la place des tuiles et des curseurs
        Loader {
            active: volet.page !== "accueil"
            y: volet.hauteurLecteur
            width: parent.width
            height: volet.piedY
            sourceComponent: volet.page === "wifi" ? pageWifi : (volet.page === "bluetooth" ? pageBluetooth : pageSon)
        }
        Component {
            id: pageWifi
            PageWifi {
                etat: volet.etat
                onRetour: volet.page = "accueil"
            }
        }
        Component {
            id: pageBluetooth
            PageBluetooth {
                etat: volet.etat
                onRetour: volet.page = "accueil"
            }
        }
        Component {
            id: pageSon
            PageSon {
                etat: volet.etat
                onRetour: volet.page = "accueil"
            }
        }

        // Bande du bas : batterie, réglages
        Rectangle {
            y: volet.hauteurLecteur + volet.piedY
            width: parent.width
            height: 40
            color: couleurs.pied

            Rectangle {
                width: parent.width
                height: 1
                color: couleurs.separateur
            }
            Row {
                visible: volet.etat.batterieDisponible
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Kirigami.Icon {
                    width: 16
                    height: 16
                    anchors.verticalCenter: parent.verticalCenter
                    source: volet.etat.iconeBatterie
                    isMask: true
                    color: Kirigami.Theme.textColor
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: volet.etat.batteriePourcent + " %"
                    font: Kirigami.Theme.smallFont
                    color: Kirigami.Theme.textColor
                }
            }
            BoutonDiscret {
                x: parent.width - 16 - 24
                anchors.verticalCenter: parent.verticalCenter
                // Engrenage, comme Windows 11 (« configure » et
                // « settings-configure » de Breeze 6 sont des curseurs)
                icone: "applications-system-symbolic"
                infobulle: "Tous les paramètres"
                onClique: volet.etat.ouvrir("")
            }
        }
    }
}
