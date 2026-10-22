/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Page d'accueil du Démarrer d'Ankh (D-052, lot 5), comme celle de Windows
// 11 : « Épinglé » et son bouton « Toutes les applications › », la grille
// des épingles, puis « Recommandé ». Elle occupe le corps du volet, sous le
// champ de recherche : ses positions sont celles de Mesures.qml (depuis le
// haut du volet) moins le haut du corps.

import QtQuick

FocusScope {
    id: accueil

    // Le volet (Demarrer.qml) ; Item, car il contient lui-même ce type
    property Item demarrer: null
    property QtObject epingles: null
    property QtObject applications: null
    property QtObject documents: null
    readonly property alias grille: grille
    readonly property alias recommande: recommande
    readonly property alias boutonToutes: boutonToutes

    signal toutesDemandees()

    function reinitialiser(): void {
        grille.reinitialiser();
        recommande.vue.currentIndex = recommande.count > 0 ? 0 : -1;
    }

    Titre {
        x: Mesures.bordTexte
        anchors.baseline: parent.top
        anchors.baselineOffset: Mesures.titreLigneDeBase - Mesures.rechercheHaut - Mesures.rechercheHauteur
        text: "Épinglé"
    }

    Bouton {
        id: boutonToutes
        x: Mesures.largeurVolet - Mesures.bordTexte - width
        y: Mesures.boutonHaut - Mesures.rechercheHaut - Mesures.rechercheHauteur
        texte: "Toutes les applications"
        chevronApres: true
        plein: true
        onClicked: accueil.toutesDemandees()
    }

    GrilleEpingles {
        id: grille
        x: Mesures.bordGrille
        y: Mesures.grilleHaut - Mesures.rechercheHaut - Mesures.rechercheHauteur
        width: implicitWidth
        height: implicitHeight
        demarrer: accueil.demarrer
        model: accueil.epingles
        focus: true
        onSortieHaut: accueil.demarrer?.focusRecherche()
        onSortieBas: {
            if (recommande.count > 0) {
                recommande.vue.currentIndex = 0;
                recommande.vue.forceActiveFocus(Qt.TabFocusReason);
            } else {
                accueil.demarrer?.focusPied();
            }
        }
    }

    Titre {
        x: Mesures.bordTexte
        anchors.baseline: parent.top
        anchors.baselineOffset: Mesures.recommandeLigneDeBase - Mesures.rechercheHaut - Mesures.rechercheHauteur
        text: "Recommandé"
    }

    Recommande {
        id: recommande
        x: Mesures.bordGrille
        y: Mesures.recommandeHaut - Mesures.rechercheHaut - Mesures.rechercheHauteur
        width: implicitWidth
        height: implicitHeight
        demarrer: accueil.demarrer
        applications: accueil.applications
        documents: accueil.documents
        onSortieHaut: {
            grille.vue.currentIndex = Math.max(0, grille.count - 1);
            grille.vue.forceActiveFocus(Qt.BacktabFocusReason);
        }
        onSortieBas: accueil.demarrer?.focusPied()
    }
}
