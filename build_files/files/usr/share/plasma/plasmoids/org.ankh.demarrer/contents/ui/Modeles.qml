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

// Les modèles du Démarrer d'Ankh (D-052, lot 5), repris de Kickoff
// (applets/kickoff/main.qml de plasma-desktop 6.7.5). Ils viennent du module
// privé de Plasma org.kde.plasma.private.kicker (applets/kicker de
// plasma-workspace 6.7.5), sans promesse de stabilité d'une version à
// l'autre : la construction de l'image crée ce fichier hors écran et échoue
// au moindre avertissement (build_files/plasma/verifier-demarrer.sh).
// Rien ici ne dépend de Plasmoid : main.qml lui passe l'applet et sa
// configuration.

import QtQuick

import org.kde.plasma.private.kicker as Kicker

QtObject {
    id: modeles

    // L'applet (PlasmoidItem), pour les actions « Ajouter au bureau » et
    // « Épingler à la barre des tâches » de Kicker ; null hors de Plasma
    property QtObject applet: null
    // Client des épingles : leur ordre est rangé sous ce nom dans
    // kactivitymanagerd-statsrc. Sans tiret avant le numéro de l'instance :
    // KAStatsFavoritesModel découpe ce nom sur les tirets pour reprendre
    // l'ordre d'un autre menu (kastatsfavoritesmodel.cpp:218-240)
    property string idClient: ""
    property bool triAlphabetique: true
    // Reprise unique des favoris (kicker-extra-favoritesrc d'Ankh, puis
    // anciens favoris), comme Kickoff
    property bool aReprendre: false
    property var anciensFavoris: []
    signal favorisRepris()

    // Toutes les applications, à plat, avec les épingles en ligne 0
    // (« KICKER_FAVORITES_MODEL ») et la liste alphabétique en ligne 1
    // (« KICKER_ALL_MODEL », rootmodel.cpp:363-463 et 553)
    readonly property Kicker.RootModel racine: Kicker.RootModel {
        autoPopulate: false
        appletInterface: modeles.applet
        // 0 : le nom seul (Kicker::NameOnly), comme Windows 11
        appNameFormat: 0
        flat: true
        sorted: modeles.triAlphabetique
        showSeparators: false
        showRootSeparator: false
        showTopLevelItems: true
        showAllApps: true
        showAllAppsCategorized: false
        showRecentApps: false
        showRecentDocs: false
        showPowerSession: false
        showFavoritesPlaceholder: true
        // Rôle isNewlyInstalled : les applications ajoutées récemment
        // alimentent « Recommandé »
        highlightNewlyInstalledApps: true

        Component.onCompleted: {
            favoritesModel.initForClient(modeles.idClient);
            if (modeles.aReprendre) {
                if (favoritesModel.count < 1) {
                    favoritesModel.portOldFavorites(modeles.anciensFavoris);
                }
                modeles.favorisRepris();
            }
        }
    }

    // Épingles : KAStatsFavoritesModel, partagé avec Kickoff et Kicker
    // (l'ensemble, pas l'ordre)
    readonly property QtObject epingles: racine.favoritesModel

    // Liste alphabétique : recalculée à chaque actualisation de la racine,
    // modelForRow ne créant pas de dépendance (ApplicationsPage.qml de Kickoff)
    property int ligneToutes: 1
    readonly property QtObject toutes: racine.modelForRow(ligneToutes)

    // Résultats de recherche des lanceurs de KRunner (ceux de krunnerrc)
    readonly property Kicker.RunnerModel resultats: Kicker.RunnerModel {
        appletInterface: modeles.applet
        mergeResults: true
        favoritesModel: modeles.racine.favoritesModel
    }

    // Documents récents, pour « Recommandé »
    readonly property Kicker.RecentUsageModel recents: Kicker.RecentUsageModel {
        favoritesModel: modeles.racine.favoritesModel
        shownItems: Kicker.RecentUsageModel.OnlyDocs
        ordering: Kicker.RecentUsageModel.Recent
    }

    // Verrouiller, se déconnecter, changer d'utilisateur, veille, arrêter,
    // redémarrer : seules les actions que la machine permet sont présentes
    // (SessionManagement::can*, systementry.cpp:79-123)
    readonly property Kicker.SystemModel systeme: Kicker.SystemModel {
        favoritesModel: modeles.racine.systemFavoritesModel
    }

    readonly property Kicker.ProcessRunner processus: Kicker.ProcessRunner {}

    readonly property Connections suiviRacine: Connections {
        target: modeles.racine
        function onRefreshed() {
            modeles.ligneToutesChanged();
        }
    }

    // Remplit la racine (autoPopulate est faux, comme dans Kickoff)
    function actualiser(): void {
        racine.refresh();
    }

    // Éditeur du menu de KDE (« Modifier les applications… »)
    function modifierApplications(): void {
        processus.runMenuEditor();
    }
}
