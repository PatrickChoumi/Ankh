/*
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
    SPDX-FileCopyrightText: 2020 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Kai Uwe Broulik <kde@broulik.de>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Pied du Démarrer d'Ankh, comme celui de Windows 11 (A, Mesures.qml) : 64
// de haut, un trait en haut, un fond un peu plus soutenu que le volet ; le
// compte à gauche (avatar de 32 à 64 du bord, nom 12 px plus loin), le
// bouton d'alimentation à droite (bord à 64). L'avatar et le nom viennent
// de Header.qml de Kickoff, les actions de LeaveButtons.qml (plasma-desktop
// 6.7.5) : SystemModel de Kicker, qui ne donne que les actions que la
// machine permet. Menus de Qt (PlasmaExtras.Menu), dessinés par le style
// d'Ankh (lot 3).
// Compte : Paramètres du compte, Changer d'utilisateur, Se déconnecter.
// Alimentation : Verrouiller, Mettre en veille, Arrêter, Redémarrer.

import QtQuick
import QtQuick.Templates as T

import org.kde.coreaddons as KCoreAddons
import org.kde.config as KConfig
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.extras as PlasmaExtras

Item {
    id: pied

    // Le volet (Demarrer.qml) ; Item, car il contient lui-même ce type
    property Item demarrer: null
    // SystemModel de Kicker (Modeles.qml) ; null dans un aperçu
    property QtObject systeme: null
    readonly property alias boutonCompte: boutonCompte
    readonly property alias boutonAlimentation: boutonAlimentation
    // Identifiants des actions disponibles (systementry.cpp:281-302)
    property var disponibles: []

    // Actions des deux menus, dans l'ordre de Windows 11 ; icônes de Breeze
    readonly property var actionsCompte: [
        { id: "kcm_users", texte: "Paramètres du compte", icone: "user-properties" },
        { id: "switch-user", texte: "Changer d'utilisateur", icone: "system-switch-user" },
        { id: "logout", texte: "Se déconnecter", icone: "system-log-out" }
    ]
    readonly property var actionsAlimentation: [
        { id: "lock-screen", texte: "Verrouiller", icone: "system-lock-screen" },
        { id: "suspend", texte: "Mettre en veille", icone: "system-suspend" },
        { id: "shutdown", texte: "Arrêter", icone: "system-shutdown" },
        { id: "reboot", texte: "Redémarrer", icone: "system-reboot" }
    ]

    function lireDisponibles(): void {
        const liste = [];
        if (systeme) {
            const role = systeme.KItemModels.KRoleNames.role("favoriteId");
            for (let i = 0; i < systeme.count; ++i) {
                liste.push(systeme.data(systeme.index(i, 0), role));
            }
        }
        if (KConfig.KAuthorized.authorizeControlModule("kcm_users")) {
            liste.push("kcm_users");
        }
        disponibles = liste;
    }

    function declencher(id: string): void {
        if (id === "kcm_users") {
            KCM.KCMLauncher.openSystemSettings("kcm_users");
        } else if (systeme) {
            const role = systeme.KItemModels.KRoleNames.role("favoriteId");
            for (let i = 0; i < systeme.count; ++i) {
                if (systeme.data(systeme.index(i, 0), role) === id) {
                    systeme.trigger(i, "", null);
                    break;
                }
            }
        }
        demarrer?.fermerApresLancement();
    }

    onSystemeChanged: lireDisponibles()
    Component.onCompleted: lireDisponibles()
    Connections {
        target: pied.systeme
        ignoreUnknownSignals: true
        function onModelReset() { pied.lireDisponibles(); }
        function onCountChanged() { pied.lireDisponibles(); }
    }

    KCoreAddons.KUser {
        id: utilisateur
    }

    // Fond du pied, aux coins du bas arrondis comme le volet (8), en retrait
    // de 1 px pour laisser voir son contour
    Item {
        anchors.fill: parent
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        anchors.bottomMargin: 1
        clip: true

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height + 16
            radius: 7
            color: Kirigami.Theme.textColor
            opacity: Mesures.opacitePied
        }
    }

    // Trait de séparation, sur toute la largeur
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: Kirigami.Theme.textColor
        opacity: Mesures.opaciteTrait
    }

    T.AbstractButton {
        id: boutonCompte

        x: Mesures.bordTexte - Mesures.recommandeRetrait
        anchors.verticalCenter: parent.verticalCenter
        height: Mesures.boutonPied
        width: Math.min(implicitWidth, Mesures.largeurVolet / 2)
        implicitWidth: leftPadding + Mesures.avatar + Mesures.ecartAvatarNom + nom.implicitWidth + rightPadding
        leftPadding: Mesures.recommandeRetrait
        rightPadding: Mesures.recommandeRetrait
        hoverEnabled: true
        Accessible.role: Accessible.ButtonMenu
        Accessible.name: "Compte : " + nom.text
        down: pressed || menuCompte.status === PlasmaExtras.Menu.Open
        Keys.onReturnPressed: clicked()
        Keys.onEnterPressed: clicked()
        Keys.onSpacePressed: clicked()
        onClicked: {
            menuCompte.visualParent = boutonCompte;
            menuCompte.openRelative();
        }

        contentItem: Item {
            KirigamiComponents.Avatar {
                id: avatar
                width: Mesures.avatar
                height: Mesures.avatar
                anchors.verticalCenter: parent.verticalCenter
                name: nom.text
                // L'adresse de l'image change deux fois de suite : pas de
                // cache (comme Kickoff)
                cache: false
                source: utilisateur.faceIconUrl
            }
            Text {
                id: nom
                anchors.left: avatar.right
                anchors.leftMargin: Mesures.ecartAvatarNom
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: utilisateur.fullName !== "" ? utilisateur.fullName : utilisateur.loginName
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.family: Kirigami.Theme.defaultFont.family
                font.pixelSize: Mesures.texteLegende
                color: Kirigami.Theme.textColor
            }
        }
        background: Survol {
            survole: boutonCompte.hovered
            appuye: boutonCompte.down
            anneau: boutonCompte.activeFocus && (pied.demarrer?.clavier ?? false)
        }
    }

    T.AbstractButton {
        id: boutonAlimentation

        x: Mesures.largeurVolet - Mesures.bordTexte - Mesures.glyphe - (Mesures.boutonPied - Mesures.glyphe) / 2
        anchors.verticalCenter: parent.verticalCenter
        width: Mesures.boutonPied
        height: Mesures.boutonPied
        hoverEnabled: true
        Accessible.role: Accessible.ButtonMenu
        Accessible.name: "Marche/Arrêt"
        down: pressed || menuAlimentation.status === PlasmaExtras.Menu.Open
        Keys.onReturnPressed: clicked()
        Keys.onEnterPressed: clicked()
        Keys.onSpacePressed: clicked()
        onClicked: {
            menuAlimentation.visualParent = boutonAlimentation;
            menuAlimentation.openRelative();
        }

        contentItem: Item {
            Kirigami.Icon {
                anchors.centerIn: parent
                width: Mesures.glyphe
                height: Mesures.glyphe
                source: "system-shutdown-symbolic"
                color: Kirigami.Theme.textColor
                isMask: true
            }
        }
        background: Survol {
            survole: boutonAlimentation.hovered
            appuye: boutonAlimentation.down
            anneau: boutonAlimentation.activeFocus && (pied.demarrer?.clavier ?? false)
        }
    }

    PlasmaExtras.Menu {
        id: menuCompte
        placement: PlasmaExtras.Menu.TopPosedLeftAlignedPopup
    }
    PlasmaExtras.Menu {
        id: menuAlimentation
        placement: PlasmaExtras.Menu.TopPosedRightAlignedPopup
    }

    Instantiator {
        model: pied.actionsCompte.filter(action => pied.disponibles.includes(action.id))
        delegate: ElementMenu {}
        onObjectAdded: (index, objet) => menuCompte.addMenuItem(objet)
        onObjectRemoved: (index, objet) => menuCompte.removeMenuItem(objet)
    }
    Instantiator {
        model: pied.actionsAlimentation.filter(action => pied.disponibles.includes(action.id))
        delegate: ElementMenu {}
        onObjectAdded: (index, objet) => menuAlimentation.addMenuItem(objet)
        onObjectRemoved: (index, objet) => menuAlimentation.removeMenuItem(objet)
    }

    component ElementMenu: PlasmaExtras.MenuItem {
        id: elementMenu
        required property var modelData
        text: modelData.texte
        icon: modelData.icone
        onClicked: pied.declencher(elementMenu.modelData.id)
    }
}
