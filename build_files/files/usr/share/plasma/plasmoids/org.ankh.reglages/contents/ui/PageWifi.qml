/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

// Page Wi-Fi des paramètres rapides (D-052, lot 6a) : la liste des réseaux
// Wi-Fi, comme derrière la flèche de la tuile Wi-Fi de Windows 11. La
// logique de connexion est celle de l'applet réseau de Plasma
// (applet/ConnectionItem.qml de plasma-nm 6.7.5, même licence) : un réseau connu se
// connecte directement ; un réseau nouveau au mot de passe statique (WEP,
// WPA, WPA2, WPA3) demande ce mot de passe ; un réseau ouvert se connecte
// sans rien demander. Les autres cas (entreprise…) passent par les réglages.

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.networkmanagement as PlasmaNM
import org.ankh.commun

PageListe {
    id: page

    required property var etat

    titre: "Wi-Fi"
    avecInterrupteur: true
    interrupteur: etat.wifiActif
    lien: "Plus de paramètres Wi-Fi"
    onBascule: etat.basculerWifi()
    onLienClique: etat.ouvrir("kcm_networkmanagement")

    // Le réseau ouvert, qui montre son mot de passe ou ses boutons
    property string ouvert: ""

    Component.onCompleted: etat.chercherReseaux()

    Couleurs {
        id: couleurs
    }

    ListView {
        id: liste
        anchors.fill: parent
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        QQC2.ScrollBar.vertical: QQC2.ScrollBar {}

        model: KItemModels.KSortFilterProxyModel {
            sourceModel: page.etat.reseaux
            filterRoleName: "Type"
            filterRowCallback: (ligne, parent) => sourceModel.data(sourceModel.index(ligne, 0, parent), filterRole) === PlasmaNM.Enums.Wireless
        }

        delegate: Rectangle {
            id: reseau

            required property var model

            readonly property bool connecte: model.ConnectionState === PlasmaNM.Enums.Activated
            readonly property bool enCours: model.ConnectionState === PlasmaNM.Enums.Activating
            readonly property bool securise: model.SecurityType !== PlasmaNM.Enums.NoneSecurity
            readonly property bool motDePasseStatique: model.SecurityType === PlasmaNM.Enums.StaticWep
                || model.SecurityType === PlasmaNM.Enums.WpaPsk || model.SecurityType === PlasmaNM.Enums.Wpa2Psk
                || model.SecurityType === PlasmaNM.Enums.SAE
            readonly property bool demandeMotDePasse: !model.Uuid && motDePasseStatique
            readonly property bool estOuvert: page.ouvert === model.ItemUniqueName

            x: page.marge - 8
            width: ListView.view.width - 2 * (page.marge - 8)
            height: estOuvert ? 52 + actions.height + 12 : 52
            radius: 4
            color: estOuvert || zone.pressed ? couleurs.discretAppui : (zone.containsMouse ? couleurs.discretSurvol : "transparent")

            MouseArea {
                id: zone
                anchors.fill: parent
                hoverEnabled: true
                onClicked: page.ouvert = reseau.estOuvert ? "" : reseau.model.ItemUniqueName
            }

            Kirigami.Icon {
                x: 12
                y: 18
                width: 16
                height: 16
                source: reseau.model.ConnectionIcon
                isMask: true
                color: Kirigami.Theme.textColor
            }
            Column {
                x: 40
                y: 9
                width: parent.width - x - 12
                Text {
                    width: parent.width
                    text: reseau.model.ItemUniqueName
                    elide: Text.ElideRight
                    color: Kirigami.Theme.textColor
                }
                Text {
                    width: parent.width
                    text: reseau.connecte ? (reseau.securise ? "Connecté, sécurisé" : "Connecté, ouvert")
                        : reseau.enCours ? "Connexion…" : (reseau.securise ? "Sécurisé" : "Ouvert")
                    elide: Text.ElideRight
                    font: Kirigami.Theme.smallFont
                    color: couleurs.texteSecondaire
                }
            }

            // Mot de passe et boutons, quand le réseau est ouvert
            Column {
                id: actions
                visible: reseau.estOuvert
                x: 40
                y: 52
                width: parent.width - x - 12
                spacing: 8

                QQC2.TextField {
                    id: motDePasse
                    visible: reseau.demandeMotDePasse && !reseau.connecte
                    width: parent.width
                    echoMode: TextInput.Password
                    placeholderText: "Entrez la clé de sécurité réseau"
                    onAccepted: bouton.clicked()
                }
                QQC2.Button {
                    id: bouton
                    anchors.right: parent.right
                    highlighted: !reseau.connecte
                    text: reseau.connecte ? "Se déconnecter" : (reseau.demandeMotDePasse ? "Suivant" : "Se connecter")
                    enabled: reseau.connecte || !reseau.demandeMotDePasse || motDePasse.text.length >= 8
                        || reseau.model.SecurityType === PlasmaNM.Enums.StaticWep
                    onClicked: {
                        if (reseau.connecte) {
                            page.etat.deconnecter(reseau.model.ConnectionPath, reseau.model.DevicePath);
                        } else if (reseau.model.Uuid) {
                            page.etat.connecter(reseau.model.ConnectionPath, reseau.model.DevicePath, reseau.model.SpecificPath);
                        } else {
                            page.etat.connecterNouveau(reseau.model.DevicePath, reseau.model.SpecificPath,
                                reseau.demandeMotDePasse ? motDePasse.text : "");
                        }
                        page.ouvert = "";
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: liste.count === 0
            text: page.etat.wifiActif ? "Aucun réseau Wi-Fi trouvé" : "Le Wi-Fi est désactivé"
            color: couleurs.texteSecondaire
        }
    }
}
