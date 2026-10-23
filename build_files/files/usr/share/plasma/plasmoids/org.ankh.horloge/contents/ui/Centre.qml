/*
    SPDX-FileCopyrightText: 2026 Ankh
    SPDX-FileCopyrightText: Ne pas déranger et historique d'après applets/notifications de plasma-workspace 6.7.5 (KDE)

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

// Volet de l'horloge d'Ankh (D-052, lot 6b ; mon choix du 2026-10-22) :
// comme Windows 11, les notifications en haut et le calendrier en bas. Les
// notifications sont l'historique de Plasma (org.kde.notificationmanager,
// réglé comme celui de l'applet des notifications : applets/notifications/
// main.qml de plasma-workspace 6.7.5) ; les bulles restent celles de Plasma.
// En tête : « Notifications », le bouton Ne pas déranger et « Tout
// effacer ». Volet de 364 de large, cadre compris (observé sous Windows 11,
// D-052, À VALIDER).

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager

import org.ankh.commun

Item {
    id: centre

    property int margeGauche: 4
    property int margeHaut: 4
    property int margeDroite: 4
    property int margeBas: 4

    readonly property int largeurVisible: 364
    // Hauteur de la liste : ses cartes, jusqu'à 420 px ; un message sinon
    readonly property int hauteurListe: liste.count === 0 ? 96 : Math.min(420, liste.contentHeight + 8)
    readonly property int hauteurVisible: 48 + hauteurListe + 1 + calendrier.implicitHeight

    // Taille demandée à Plasma (Layout de main.qml) : calculée, et non lue sur
    // width et height, que Plasma impose ensuite au volet
    readonly property int largeurContenu: largeurVisible - margeGauche - margeDroite
    readonly property int hauteurContenu: hauteurVisible - margeHaut - margeBas
    width: largeurContenu
    height: hauteurContenu

    // « Tout effacer », comme Windows 11 : l'historique (comme l'applet des
    // notifications, ClearExpired), puis les notifications encore en bulle
    function toutEffacer(): void {
        historique.clear(NotificationManager.Notifications.ClearExpired);
        for (let i = historique.count - 1; i >= 0; i--) {
            const idx = historique.index(i, 0);
            if (historique.data(idx, NotificationManager.Notifications.ClosableRole)
                    && !historique.data(idx, NotificationManager.Notifications.ExpiredRole)) {
                historique.close(idx);
            }
        }
    }

    function revenirAujourdhui(): void {
        calendrier.aujourdhui = new Date();
        calendrier.revenirAujourdhui();
    }

    Couleurs {
        id: couleurs
    }

    // Ne pas déranger : tenu par main.qml, que la cloche de la barre suit
    property bool nePasDeranger: false
    signal basculerNePasDeranger()

    // Listes d'exclusion de l'historique, comme l'applet des notifications
    NotificationManager.Settings {
        id: reglages
        live: true
    }

    NotificationManager.Notifications {
        id: historique
        showExpired: true
        showDismissed: true
        showJobs: false
        sortMode: NotificationManager.Notifications.SortByDate
        groupMode: NotificationManager.Notifications.GroupDisabled
        ignoreBlacklistDuringInhibition: true
        blacklistedDesktopEntries: reglages.historyBlacklistedApplications
        blacklistedNotifyRcNames: reglages.historyBlacklistedServices
        urgencies: NotificationManager.Notifications.CriticalUrgency | NotificationManager.Notifications.NormalUrgency
            | (reglages.lowPriorityHistory ? NotificationManager.Notifications.LowUrgency : 0)
    }

    Item {
        x: -centre.margeGauche
        y: -centre.margeHaut
        width: centre.largeurVisible
        height: centre.hauteurVisible

        // En tête
        Item {
            id: entete
            width: parent.width
            height: 48
            Text {
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "Notifications"
                font.family: Kirigami.Theme.defaultFont.family
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: Kirigami.Theme.textColor
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                BoutonDiscret {
                    icone: centre.nePasDeranger ? "notifications-disabled-symbolic" : "notifications-symbolic"
                    infobulle: centre.nePasDeranger ? "Désactiver Ne pas déranger" : "Ne pas déranger"
                    enfonce: centre.nePasDeranger
                    onClique: centre.basculerNePasDeranger()
                }
                Rectangle {
                    visible: historique.count > 0
                    width: texteEffacer.implicitWidth + 16
                    height: 32
                    radius: 4
                    color: zoneEffacer.pressed ? couleurs.discretAppui : (zoneEffacer.containsMouse ? couleurs.discretSurvol : "transparent")
                    Text {
                        id: texteEffacer
                        anchors.centerIn: parent
                        text: "Tout effacer"
                        color: Kirigami.Theme.textColor
                    }
                    MouseArea {
                        id: zoneEffacer
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: centre.toutEffacer()
                    }
                }
            }
        }

        // Liste
        ListView {
            id: liste
            y: 48
            x: 12
            width: parent.width - 24
            height: centre.hauteurListe
            clip: true
            spacing: 8
            boundsBehavior: Flickable.StopAtBounds
            QQC2.ScrollBar.vertical: QQC2.ScrollBar {}
            model: historique
            delegate: Notification {
                required property int index
                width: ListView.view.width
                onFermee: historique.close(historique.index(index, 0))
                onActivee: historique.invokeDefaultAction(historique.index(index, 0), NotificationManager.Notifications.Close)
            }
            Text {
                anchors.centerIn: parent
                visible: liste.count === 0
                text: "Aucune nouvelle notification"
                color: couleurs.texteSecondaire
            }
        }

        Rectangle {
            y: 48 + centre.hauteurListe
            width: parent.width
            height: 1
            color: couleurs.separateur
        }

        Calendrier {
            id: calendrier
            y: 48 + centre.hauteurListe + 1
            width: parent.width
            height: implicitHeight
        }
    }
}
