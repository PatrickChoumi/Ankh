/*
    SPDX-FileCopyrightText: 2013 Aurélien Gâteau <agateau@kde.org>
    SPDX-FileCopyrightText: 2013-2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2017 Ivan Cukic <ivan.cukic@kde.org>
    SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Actions du menu contextuel des éléments du Démarrer d'Ankh (D-052, lot 5),
// reprises de Kickoff (applets/kickoff/code/tools.js de plasma-desktop
// 6.7.5). Les textes sont écrits en français, sans catalogue de traduction ;
// « Épingler à l'écran de démarrage » reprend la formulation de Windows en
// français (À VALIDER). Les identifiants _kicker_favorite_* sont ceux de
// Kickoff.

.pragma library

// Actions « Épingler » et « Détacher », ou leur sous-menu par activité
function createFavoriteActions(favoriteModel, favoriteId) {
    if (!favoriteModel || !favoriteId || !favoriteModel.enabled) {
        return null;
    }

    if (favoriteModel.activities === undefined ||
        favoriteModel.activities.activities.length <= 1) {
        const action = {};

        if (favoriteModel.isFavorite(favoriteId)) {
            action.text = "Détacher de l'écran de démarrage";
            action.icon = "window-unpin";
            action.actionId = "_kicker_favorite_remove";
        } else if (favoriteModel.maxFavorites === -1 || favoriteModel.count < favoriteModel.maxFavorites) {
            action.text = "Épingler à l'écran de démarrage";
            action.icon = "window-pin";
            action.actionId = "_kicker_favorite_add";
        } else {
            return null;
        }

        action.actionArgument = { favoriteModel: favoriteModel, favoriteId: favoriteId };

        return [action];

    } else {
        const subActions = [];

        const linkedActivities = favoriteModel.linkedActivitiesFor(favoriteId);

        const activities = favoriteModel.activities.activities;

        // Épinglé dans toutes les activités, ou non
        const linkedToAllActivities =
            !(linkedActivities.indexOf(":global") === -1);

        subActions.push({
            text      : "Dans toutes les activités",
            checkable : true,

            actionId  : linkedToAllActivities ?
                            "_kicker_favorite_remove_from_activity" :
                            "_kicker_favorite_set_to_activity",
            checked   : linkedToAllActivities,

            actionArgument : {
                favoriteModel: favoriteModel,
                favoriteId: favoriteId,
                favoriteActivity: "",
            },
        });

        // Une entrée par activité
        const addActivityItem = function(activityId, activityName) {
            const linkedToThisActivity =
                !(linkedActivities.indexOf(activityId) === -1);

            subActions.push({
                text      : activityName,
                checkable : true,
                checked   : linkedToThisActivity && !linkedToAllActivities,

                actionId :
                    // Épinglé partout : choisir une activité retire les autres
                    linkedToAllActivities ? "_kicker_favorite_set_to_activity" :

                    // Épinglé dans cette activité : on l'en retire seulement
                    linkedToThisActivity ? "_kicker_favorite_remove_from_activity" :

                    // Sinon, on l'ajoute à cette activité, sans toucher aux autres
                    "_kicker_favorite_add_to_activity",

                actionArgument : {
                    favoriteModel    : favoriteModel,
                    favoriteId       : favoriteId,
                    favoriteActivity : activityId,
                },
            });
        };

        addActivityItem(favoriteModel.activities.currentActivity, "Dans l'activité en cours");

        subActions.push({
            type: "separator",
            actionId: "_kicker_favorite_separator",
        });

        activities.forEach(function(activityId) {
            addActivityItem(activityId, favoriteModel.activityNameForId(activityId));
        });

        return [{
            text       : "Épingler à l'écran de démarrage",
            icon       : "window-pin",
            subActions,
        }];
    }
}

// Déclenche une action ; vrai si le modèle demande de fermer le volet
function triggerAction(model, index, actionId, actionArgument) {
    if (actionId.startsWith("_kicker_favorite_")) {
        handleFavoriteAction(actionId, actionArgument);
        return false;
    }

    return model.trigger(index, actionId, actionArgument) === true;
}

function handleFavoriteAction(actionId, actionArgument) {
    const favoriteId = actionArgument.favoriteId;
    const favoriteModel = actionArgument.favoriteModel;

    if (favoriteModel === null || favoriteId === null) {
        return;
    }

    if (actionId === "_kicker_favorite_remove") {
        favoriteModel.removeFavorite(favoriteId);
    } else if (actionId === "_kicker_favorite_add") {
        favoriteModel.addFavorite(favoriteId);
    } else if (actionId === "_kicker_favorite_remove_from_activity") {
        favoriteModel.removeFavoriteFrom(favoriteId, actionArgument.favoriteActivity);
    } else if (actionId === "_kicker_favorite_add_to_activity") {
        favoriteModel.addFavoriteTo(favoriteId, actionArgument.favoriteActivity);
    } else if (actionId === "_kicker_favorite_set_to_activity") {
        favoriteModel.setFavoriteOn(favoriteId, actionArgument.favoriteActivity);
    }
}
