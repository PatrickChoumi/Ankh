// Sonde du Démarrer d'Ankh (D-052, lot 5), lancée hors écran à la
// construction par verifier-demarrer.sh, à côté d'une copie du paquet
// (dossier « paquet »). Elle crée les vrais modèles du menu (Modeles.qml :
// module privé org.kde.plasma.private.kicker de plasma-workspace) et le
// volet entier (Demarrer.qml), puis vérifie chaque type, propriété, rôle et
// méthode dont le menu se sert. Une propriété, un type ou un module disparu
// fait échouer le chargement ; une valeur d'énumération disparue ne donne
// qu'un avertissement « file://….qml:L:C: », que le script refuse aussi
// (recherche du lot 5, § 4). Les messages passent par console.warn :
// console.log est filtré par Qt de Fedora.

import QtQuick

import org.kde.kitemmodels as KItemModels
import org.kde.plasma.private.kicker as Kicker

import "paquet/contents/ui" as Ankh
import "paquet/contents/ui/code/tools.js" as Outils

Item {
    id: sonde

    property var erreurs: []
    // Code de sortie, rendu quand la recherche est terminée (fin, plus bas)
    property int codeSortie: 0

    width: 640
    height: 726

    function exiger(condition: bool, message: string): void {
        if (!condition) {
            erreurs.push(message);
        }
    }

    function exigerMethodes(objet: QtObject, nom: string, methodes: var): void {
        for (const methode of methodes) {
            exiger(objet !== null && typeof objet[methode] === "function", nom + "." + methode + "() absente");
        }
    }

    function exigerRoles(modele: QtObject, nom: string, roles: var): void {
        for (const role of roles) {
            exiger(modele !== null && modele.KItemModels.KRoleNames.role(role) >= 0, "rôle « " + role + " » absent de " + nom);
        }
    }

    Ankh.Modeles {
        id: modeles
        idClient: "org.ankh.demarrer.favorites.instance-0"
    }

    // Le volet entier, avec les vrais modèles, à la place qu'il a dans le
    // cadre d'un volet de Plasma (marges de 4)
    Ankh.Demarrer {
        id: volet
        x: 4
        y: 4
        width: Ankh.Mesures.largeurVolet - 8
        height: Ankh.Mesures.hauteurVolet - 8
        margeGauche: 4
        margeHaut: 4
        margeDroite: 4
        margeBas: 4
        modeles: modeles
    }

    Timer {
        interval: 3000
        running: true
        onTriggered: sonde.verifier()
    }

    function verifier(): void {
        // Mesures (singleton déclaré dans qmldir)
        exiger(Ankh.Mesures.largeurVolet === 640 && Ankh.Mesures.hauteurVolet === 726,
            "Mesures.qml n'est pas lu comme singleton (qmldir)");

        // Modèles de Kicker
        exiger(modeles.racine !== null, "RootModel absent");
        exiger(modeles.resultats !== null, "RunnerModel absent");
        exiger(modeles.recents !== null, "RecentUsageModel absent");
        exiger(modeles.systeme !== null, "SystemModel absent");
        exigerMethodes(modeles.racine, "RootModel", ["refresh", "modelForRow", "trigger"]);
        exiger(modeles.racine.systemFavoritesModel !== undefined, "RootModel.systemFavoritesModel absente");

        // Épingles (KAStatsFavoritesModel)
        const epingles = modeles.epingles;
        exiger(epingles !== null, "RootModel.favoritesModel absent");
        exigerMethodes(epingles, "KAStatsFavoritesModel", ["initForClient", "portOldFavorites", "isFavorite",
            "addFavorite", "addFavoriteTo", "removeFavorite", "removeFavoriteFrom", "setFavoriteOn",
            "linkedActivitiesFor", "activityNameForId", "moveRow", "trigger"]);
        exiger(epingles !== null && epingles.maxFavorites !== undefined && epingles.enabled !== undefined
            && epingles.activities !== undefined && epingles.count !== undefined,
            "KAStatsFavoritesModel : maxFavorites, enabled, activities ou count absente");
        exigerRoles(epingles, "KAStatsFavoritesModel", ["display", "decoration", "description", "favoriteId",
            "url", "actionList", "hasActionList"]);
        // Menu contextuel : le singleton ActionMenu, et les actions
        // « Épingler » de code/tools.js sur le vrai modèle des épingles
        exiger(Ankh.ActionMenu.menu !== null, "ActionMenu.qml (singleton) : menu absent");
        const actions = Outils.createFavoriteActions(epingles, "systemsettings.desktop");
        exiger(Array.isArray(actions) && actions.length === 1 && typeof actions[0].text === "string",
            "code/tools.js : createFavoriteActions ne rend pas d'action pour les épingles");

        // Toutes les applications (ligne 1 de la racine)
        const toutes = modeles.toutes;
        exiger(toutes !== null, "RootModel.modelForRow(1) absent");
        if (toutes !== null) {
            exiger(toutes.description === "KICKER_ALL_MODEL", "ligne 1 de RootModel : « " + toutes.description + " » au lieu de KICKER_ALL_MODEL");
            exiger(toutes.count > 0, "aucune application dans KICKER_ALL_MODEL");
            exiger(toutes.sections !== undefined && toutes.sections !== null, "AppsModel.sections absente");
            exiger(toutes.favoritesModel !== undefined, "AppsModel.favoritesModel absente");
            exigerMethodes(toutes, "AppsModel", ["trigger"]);
            exigerRoles(toutes, "AppsModel", ["display", "decoration", "description", "group", "favoriteId",
                "url", "actionList", "hasActionList", "isSeparator", "isNewlyInstalled"]);
            if (toutes.sections) {
                exigerRoles(toutes.sections, "SectionsModel", ["section", "firstIndex"]);
            }
        }

        // Recherche (RunnerModel)
        exigerMethodes(modeles.resultats, "RunnerModel", ["modelForRow"]);
        exiger(modeles.resultats.querying !== undefined && modeles.resultats.count !== undefined,
            "RunnerModel.querying ou count absente");
        volet.champ.text = "sonde";
        exiger(modeles.resultats.query === "sonde", "le texte du champ n'arrive pas à RunnerModel.query");
        volet.champ.text = "";

        // Récents (RecentUsageModel, documents seulement)
        exiger(Kicker.RecentUsageModel.OnlyDocs !== undefined && modeles.recents.shownItems === Kicker.RecentUsageModel.OnlyDocs,
            "RecentUsageModel.OnlyDocs absente");
        exiger(Kicker.RecentUsageModel.Recent !== undefined && modeles.recents.ordering === Kicker.RecentUsageModel.Recent,
            "RecentUsageModel.Recent absente");
        exigerRoles(modeles.recents, "RecentUsageModel", ["display", "decoration", "description", "favoriteId", "url"]);

        // Session et alimentation (SystemModel)
        exigerMethodes(modeles.systeme, "SystemModel", ["trigger"]);
        exigerRoles(modeles.systeme, "SystemModel", ["display", "decoration", "favoriteId"]);

        // Éditeur du menu
        exigerMethodes(modeles.processus, "ProcessRunner", ["runMenuEditor"]);

        // Le volet : ses vues reçoivent les modèles
        exiger(volet.page === "accueil" && volet.vueActive() !== null, "le volet n'affiche pas l'accueil");

        let lignes = [];
        lignes.push("épingles " + (epingles ? epingles.count : "?"));
        lignes.push("applications " + (toutes ? toutes.count : "?"));
        lignes.push("lettres " + (toutes && toutes.sections ? toutes.sections.rowCount() : "?"));
        lignes.push("actions système " + modeles.systeme.count);
        if (erreurs.length > 0) {
            for (const erreur of erreurs) {
                console.warn("SONDE ÉCHEC : " + erreur);
            }
            codeSortie = 1;
        } else {
            console.warn("SONDE OK : " + lignes.join(", "));
        }
        fin.start();
    }

    // Les lanceurs de KRunner cherchent dans leurs propres fils d'exécution :
    // quitter pendant la recherche lancée plus haut fait planter qml à sa
    // fermeture (« dumped core », après « SONDE OK », run 39840151935). La
    // sonde attend donc la fin de la recherche ; une recherche qui ne se
    // termine pas en 30 secondes est une erreur.
    Timer {
        id: fin
        interval: 250
        repeat: true
        property int tours: 0
        onTriggered: {
            tours++;
            if (!modeles.resultats.querying && tours >= 4) {
                stop();
                Qt.exit(sonde.codeSortie);
            } else if (tours >= 120) {
                stop();
                console.warn("SONDE ÉCHEC : la recherche de KRunner ne se termine pas en 30 secondes");
                Qt.exit(1);
            }
        }
    }
}
