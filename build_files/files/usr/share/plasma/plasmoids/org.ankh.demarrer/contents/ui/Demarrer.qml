/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 2014 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// Le volet du Démarrer d'Ankh (D-052, lot 5), adapté de
// FullRepresentation.qml de Kickoff (plasma-desktop 6.7.5), disposé comme
// le Démarrer « classique » de Windows 11 (mon choix du 2026-10-22) :
// recherche en haut, page d'accueil (épingles, recommandé) ou « Toutes les
// applications », résultats de recherche à leur place, compte et
// alimentation en bas. Toutes les positions sont celles de Mesures.qml,
// prises depuis le bord du volet visible : le contenu déborde sur les marges
// du cadre (dialogs/background du style Plasma), comme celui de Kickoff.
//
// Rien ici ne dépend de Plasmoid : main.qml passe les modèles et l'état du
// volet, et un aperçu hors de Plasma peut passer des modèles de test.
//
// Clavier : le texte tapé n'importe où arrive dans le champ de recherche
// (renvoi des touches, comme Kickoff) ; flèches dans les grilles et les
// listes, Entrée pour lancer, Échap pour effacer la recherche, revenir à
// l'accueil, puis fermer.

import QtQuick

import org.kde.kirigami as Kirigami

FocusScope {
    id: demarrer

    // Modèles (Modeles.qml) : epingles, toutes, resultats, recents, systeme
    property QtObject modeles: null
    property bool ouvert: true
    // Faux quand Plasma est verrouillé (immutability) : ni glisser ni
    // réordonner
    property bool modifiable: true
    // Le volet reste ouvert après un lancement (réglage « pin » de Kickoff)
    property bool garderOuvert: false
    // Marges du cadre du volet (fixedMargins de dialogs/background) : le
    // contenu commence à ce retrait du bord visible
    property int margeGauche: 0
    property int margeHaut: 0
    property int margeDroite: 0
    property int margeBas: 0

    // Vrai pendant la navigation au clavier : l'élément courant et l'anneau
    // de focus se montrent ; faux dès que la souris bouge
    property bool clavier: false
    // « accueil » ou « toutes »
    property string page: "accueil"
    readonly property bool enRecherche: champ.text.length > 0
    readonly property alias champ: champ

    // Objet glissé hors du volet (vers le bureau, la barre) ou dans la grille
    // des épingles ; hors de l'arbre visuel, comme dans Kickoff (bogue 449426)
    readonly property Item sourceGlisser: Item {
        property Item sourceItem: null
        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.CopyAction | Qt.LinkAction | Qt.MoveAction
    }

    // Le volet demande à se fermer (main.qml : expanded = false)
    signal fermer()

    // Lance la ligne d'un modèle de Kicker ; le volet se ferme si le
    // lancement a réussi (trigger rend vrai)
    function lancer(modele: QtObject, ligne: int): void {
        if (modele && typeof modele.trigger === "function" && modele.trigger(ligne, "", null)) {
            fermerApresLancement();
        }
    }

    function fermerApresLancement(): void {
        if (!garderOuvert) {
            fermer();
        }
    }

    function glisser(element: Item, actif: bool): void {
        if (!actif) {
            sourceGlisser.Drag.active = false;
            sourceGlisser.Drag.imageSource = "";
            sourceGlisser.sourceItem = null;
            return;
        }
        element.imageGlissee.grabToImage(resultat => {
            if (!element.glissementActif) {
                return;
            }
            sourceGlisser.sourceItem = element;
            sourceGlisser.Drag.imageSource = resultat.url;
            sourceGlisser.Drag.mimeData = { "text/uri-list": [element.adresse] };
            sourceGlisser.Drag.active = true;
        });
    }

    // Vue affichée : résultats, grille des épingles, liste ou lettres
    function vueActive(): Item {
        if (enRecherche) {
            return resultats.vue;
        }
        if (page === "toutes") {
            return toutes.lettresVisibles ? toutes.lettres.vue : toutes.liste.vue;
        }
        return accueil.grille.vue;
    }

    function entrerDansVue(): void {
        const vue = vueActive();
        if (vue && vue.count > 0) {
            if (vue.currentIndex < 0) {
                vue.currentIndex = 0;
            }
            vue.forceActiveFocus(Qt.TabFocusReason);
        }
    }

    // Entrée dans le champ : le premier résultat (meilleur résultat). Si
    // les lanceurs cherchent encore, le lancement attend la fin de leur
    // recherche, 750 ms au plus, pour ne pas lancer un résultat du texte
    // précédent (launchMatchTimer de KickoffListView.qml)
    function lancerCourant(): void {
        if (!enRecherche) {
            return;
        }
        if (modeles && modeles.resultats && modeles.resultats.querying) {
            attenteResultats.restart();
        } else {
            lancerResultat();
        }
    }

    function lancerResultat(): void {
        attenteResultats.stop();
        if (enRecherche && resultats.count > 0) {
            const element = resultats.vue.currentItem as Element;
            element?.lancer();
        }
    }

    Timer {
        id: attenteResultats
        interval: 750
        onTriggered: demarrer.lancerResultat()
    }

    function focusRecherche(): void {
        champ.forceActiveFocus(Qt.BacktabFocusReason);
    }

    function focusPied(): void {
        pied.boutonCompte.forceActiveFocus(Qt.TabFocusReason);
    }

    function afficherToutes(): void {
        toutes.reinitialiser();
        page = "toutes";
        if (clavier) {
            toutes.liste.vue.forceActiveFocus(Qt.TabFocusReason);
        }
    }

    function afficherAccueil(): void {
        page = "accueil";
        if (clavier) {
            accueil.boutonToutes.forceActiveFocus(Qt.TabFocusReason);
        }
    }

    // État de départ, à chaque fermeture : comme Windows 11, le volet
    // rouvre sur l'accueil, le champ vide et prêt à recevoir le texte
    function reinitialiser(): void {
        champ.clear();
        page = "accueil";
        accueil.reinitialiser();
        toutes.reinitialiser();
        resultats.reinitialiser();
        clavier = false;
        champ.forceActiveFocus(Qt.OtherFocusReason);
    }

    onOuvertChanged: {
        if (!ouvert) {
            reinitialiser();
        } else {
            champ.forceActiveFocus(Qt.OtherFocusReason);
        }
    }

    // Les touches qu'aucun élément n'a prises signalent la navigation au
    // clavier (Tab compris), sans être consommées
    Keys.onPressed: event => {
        clavier = true;
        event.accepted = false;
    }
    Keys.onEscapePressed: event => {
        if (champ.text !== "") {
            champ.clear();
            champ.forceActiveFocus(Qt.OtherFocusReason);
        } else if (page === "toutes" && toutes.lettresVisibles) {
            toutes.lettresVisibles = false;
            toutes.liste.vue.forceActiveFocus(Qt.OtherFocusReason);
        } else if (page !== "accueil") {
            afficherAccueil();
        } else {
            fermer();
        }
        event.accepted = true;
    }

    // Recherche : le texte du champ va aux lanceurs de KRunner
    Binding {
        target: demarrer.modeles ? demarrer.modeles.resultats : null
        property: "query"
        value: champ.text
        when: demarrer.modeles !== null && demarrer.modeles.resultats !== undefined
        restoreMode: Binding.RestoreNone
    }
    Connections {
        target: demarrer.modeles ? demarrer.modeles.resultats : null
        ignoreUnknownSignals: true
        function onRequestUpdateQuery(requete: string) {
            champ.text = requete;
        }
        function onQueryFinished() {
            if (attenteResultats.running) {
                // Laisse aux vues le temps de prendre les nouveaux résultats
                Qt.callLater(demarrer.lancerResultat);
            }
        }
    }

    // La racine de Kicker se remplit à la création du volet (autoPopulate
    // est faux), comme dans Kickoff
    Component.onCompleted: {
        if (modeles && typeof modeles.actualiser === "function") {
            modeles.actualiser();
        }
    }

    // Le volet visible, de bord à bord, par-dessus les marges du cadre
    Item {
        id: surface

        x: -demarrer.margeGauche
        y: -demarrer.margeHaut
        width: demarrer.width + demarrer.margeGauche + demarrer.margeDroite
        height: demarrer.height + demarrer.margeHaut + demarrer.margeBas

        // La souris qui bouge efface la navigation au clavier
        HoverHandler {
            onPointChanged: demarrer.clavier = false
        }

        ChampRecherche {
            id: champ
            x: Mesures.bordGrille
            y: Mesures.rechercheHaut
            width: Mesures.rechercheLargeur
            height: Mesures.rechercheHauteur
            demarrer: demarrer
        }

        // Corps : entre le champ et le pied
        Item {
            id: corps

            readonly property int decalage: Mesures.bordGrille + Mesures.boutonRetrait

            y: Mesures.rechercheHaut + Mesures.rechercheHauteur
            width: parent.width
            height: pied.y - y
            clip: true

            // Texte tapé hors du champ : il y est renvoyé (Keys.forwardTo,
            // comme Kickoff), puis le champ prend le focus
            Keys.priority: Keys.AfterItem
            Keys.forwardTo: [champ]

            PageAccueil {
                id: accueil
                width: parent.width
                height: parent.height
                readonly property bool affichee: !demarrer.enRecherche && demarrer.page === "accueil"
                x: affichee ? 0 : -corps.decalage
                opacity: affichee ? 1 : 0
                visible: opacity > 0
                enabled: affichee
                demarrer: demarrer
                epingles: demarrer.modeles ? demarrer.modeles.epingles : null
                applications: demarrer.modeles ? demarrer.modeles.toutes : null
                documents: demarrer.modeles ? demarrer.modeles.recents : null
                onToutesDemandees: demarrer.afficherToutes()

                Behavior on x { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }
            }

            PageToutes {
                id: toutes
                width: parent.width
                height: parent.height
                readonly property bool affichee: !demarrer.enRecherche && demarrer.page === "toutes"
                x: affichee ? 0 : corps.decalage
                opacity: affichee ? 1 : 0
                visible: opacity > 0
                enabled: affichee
                demarrer: demarrer
                applications: demarrer.modeles ? demarrer.modeles.toutes : null
                onRetourDemande: demarrer.afficherAccueil()

                Behavior on x { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }
            }

            // Résultats de recherche : la même liste, à la place des pages
            ListeApplications {
                id: resultats
                x: Mesures.bordGrille
                y: Mesures.boutonRetrait * 2
                width: Mesures.rechercheLargeur
                height: parent.height - y
                visible: demarrer.enRecherche
                enabled: demarrer.enRecherche
                demarrer: demarrer
                recherche: true
                model: demarrer.modeles && demarrer.modeles.resultats && demarrer.modeles.resultats.count
                    ? demarrer.modeles.resultats.modelForRow(0) : null
                sectionPropriete: "group"
                sectionCritere: ViewSection.FullString
                onSortieHaut: demarrer.focusRecherche()
            }

            Text {
                visible: demarrer.enRecherche && resultats.count === 0
                    && !(demarrer.modeles?.resultats?.querying ?? false)
                x: Mesures.bordTexte
                y: Mesures.titreLigneDeBase - Mesures.rechercheHaut - Mesures.rechercheHauteur - Mesures.texteCorps
                width: parent.width - 2 * Mesures.bordTexte
                text: "Aucun résultat pour « " + champ.text + " »."
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                font.family: Kirigami.Theme.defaultFont.family
                font.pixelSize: Mesures.texteCorps
                color: Kirigami.Theme.textColor
                opacity: Mesures.opaciteSecondaire
            }
        }

        Pied {
            id: pied
            y: parent.height - Mesures.piedHauteur
            width: parent.width
            height: Mesures.piedHauteur
            demarrer: demarrer
            systeme: demarrer.modeles ? demarrer.modeles.systeme : null

            Keys.priority: Keys.AfterItem
            Keys.forwardTo: [champ]
        }
    }
}
