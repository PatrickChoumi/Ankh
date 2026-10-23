/*
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Page « Toutes les applications » du Démarrer d'Ankh, adaptée de
// ApplicationsPage.qml de Kickoff (plasma-desktop 6.7.5, vue en liste) :
// titre et bouton « ‹ Retour » à la place de « Épinglé », puis la liste
// alphabétique ; un clic sur une lettre montre la grille des lettres, comme
// dans Windows 11. Aucune mesure de Microsoft pour cette page : la liste
// reprend la place de la grille des épingles, de 32 à 32 du bord.

import QtQuick

FocusScope {
    id: toutes

    // Le volet (Demarrer.qml) ; Item, car il contient lui-même ce type
    property Item demarrer: null
    // Liste de toutes les applications (« KICKER_ALL_MODEL ») ; ses
    // sections (SectionsModel) font la grille des lettres
    property QtObject applications: null
    property bool lettresVisibles: false
    readonly property alias liste: liste
    readonly property alias lettres: lettres
    readonly property alias boutonRetour: boutonRetour

    signal retourDemande()

    function reinitialiser(): void {
        lettresVisibles = false;
        liste.reinitialiser();
    }

    Titre {
        x: Mesures.bordTexte
        anchors.baseline: parent.top
        anchors.baselineOffset: Mesures.titreLigneDeBase - Mesures.rechercheHaut - Mesures.rechercheHauteur
        text: "Toutes les applications"
    }

    Bouton {
        id: boutonRetour
        x: Mesures.largeurVolet - Mesures.bordTexte - width
        y: Mesures.boutonHaut - Mesures.rechercheHaut - Mesures.rechercheHauteur
        texte: "Retour"
        chevronAvant: true
        plein: true
        onClicked: toutes.retourDemande()
    }

    ListeApplications {
        id: liste
        x: Mesures.bordGrille
        y: Mesures.grilleHaut - Mesures.rechercheHaut - Mesures.rechercheHauteur
        width: Mesures.colonnes * Mesures.celluleLargeur
        height: parent.height - y
        visible: !toutes.lettresVisibles
        focus: !toutes.lettresVisibles
        demarrer: toutes.demarrer
        // Les en-têtes de lettre ne valent que pour la liste alphabétique
        // (contournement de QTBUG-121797, comme Kickoff)
        model: toutes.applications
        sectionPropriete: toutes.applications && toutes.applications.description === "KICKER_ALL_MODEL" ? "group" : "_unset"
        sectionCritere: ViewSection.FirstCharacter
        onLettresDemandees: lettre => {
            lettres.lettreCourante = lettre;
            toutes.lettresVisibles = true;
            lettres.placer();
            lettres.vue.forceActiveFocus(Qt.OtherFocusReason);
        }
        onSortieHaut: boutonRetour.forceActiveFocus(Qt.BacktabFocusReason)
    }

    GrilleLettres {
        id: lettres
        x: liste.x
        y: liste.y
        width: liste.width
        height: liste.height
        visible: toutes.lettresVisibles
        focus: toutes.lettresVisibles
        demarrer: toutes.demarrer
        model: toutes.applications ? toutes.applications.sections : null
        onLettreChoisie: premiereLigne => {
            toutes.lettresVisibles = false;
            liste.allerA(premiereLigne);
            liste.vue.forceActiveFocus(Qt.OtherFocusReason);
        }
    }
}
