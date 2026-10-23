/*
    SPDX-FileCopyrightText: 2013-2014 Jan Grulich <jgrulich@redhat.com>
    SPDX-FileCopyrightText: 2014-2015 David Rosca <nowrep@gmail.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

// Page Bluetooth des paramètres rapides (D-052, lot 6a) : les appareils
// associés, comme derrière la flèche de la tuile Bluetooth de Windows 11.
// Un clic connecte ou déconnecte l'appareil, comme l'applet Bluetooth de
// Plasma (src/applet/qml/DeviceItem.qml de bluedevil 6.7.5, même licence) ;
// l'association d'un nouvel appareil passe par les réglages.

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

PageListe {
    id: page

    required property var etat

    titre: "Bluetooth"
    avecInterrupteur: true
    interrupteur: etat.btActif
    lien: "Plus de paramètres Bluetooth"
    onBascule: etat.basculerBt()
    onLienClique: etat.ouvrir("kcm_bluetooth")

    Couleurs {
        id: couleurs
    }

    ListView {
        id: liste
        anchors.fill: parent
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        QQC2.ScrollBar.vertical: QQC2.ScrollBar {}

        // Appareils associés, les connectés d'abord
        model: KItemModels.KSortFilterProxyModel {
            sourceModel: BluezQt.DevicesModel {}
            filterRoleName: "Paired"
            filterRowCallback: (ligne, parent) => sourceModel.data(sourceModel.index(ligne, 0, parent), filterRole) === true
            sortRoleName: "Connected"
            sortOrder: Qt.DescendingOrder
        }

        delegate: Rectangle {
            id: appareil

            required property var model
            property bool attente: false

            x: page.marge - 8
            width: ListView.view.width - 2 * (page.marge - 8)
            height: 52
            radius: 4
            color: zone.pressed ? couleurs.discretAppui : (zone.containsMouse ? couleurs.discretSurvol : "transparent")

            MouseArea {
                id: zone
                anchors.fill: parent
                hoverEnabled: true
                enabled: page.etat.btActif && !appareil.attente
                onClicked: {
                    appareil.attente = true;
                    const appel = appareil.model.Connected ? appareil.model.Device.disconnectFromDevice()
                                                           : appareil.model.Device.connectToDevice();
                    appel.finished.connect(() => {
                        appareil.attente = false;
                    });
                }
            }

            Kirigami.Icon {
                x: 12
                y: 18
                width: 16
                height: 16
                source: appareil.model.Icon
                isMask: true
                color: Kirigami.Theme.textColor
            }
            Column {
                x: 40
                y: 9
                width: parent.width - x - 12
                Text {
                    width: parent.width
                    text: appareil.model.Name
                    elide: Text.ElideRight
                    color: Kirigami.Theme.textColor
                }
                Text {
                    width: parent.width
                    text: appareil.attente ? (appareil.model.Connected ? "Déconnexion…" : "Connexion…")
                        : (appareil.model.Connected ? "Connecté" : "Associé")
                    font: Kirigami.Theme.smallFont
                    color: couleurs.texteSecondaire
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: liste.count === 0
            text: page.etat.btActif ? "Aucun appareil associé" : "Le Bluetooth est désactivé"
            color: couleurs.texteSecondaire
        }
    }
}
