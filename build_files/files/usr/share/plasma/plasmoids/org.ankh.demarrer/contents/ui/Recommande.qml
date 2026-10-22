/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

// « Recommandé » du Démarrer d'Ankh (D-052, lot 5) : 2 colonnes de 288 ×
// 3 rangées de 56, icône de 32, nom et détail sur deux lignes (A,
// Mesures.qml). Comme Windows 11, il montre les applications ajoutées
// récemment, puis les documents ouverts récemment :
// - applications : rôle isNewlyInstalled de la liste de toutes les
//   applications (RootModel de Kicker, highlightNewlyInstalledApps) ;
// - documents : RecentUsageModel de Kicker (OnlyDocs), lu dans la base de
//   KActivities. Kicker n'en donne pas la date d'utilisation : le détail est
//   le dossier du document (recentusagemodel.cpp:334-352), et non « il y a
//   5 min » comme dans Windows.
// Les deux modèles sont lus ligne par ligne et réunis dans une liste,
// refaite à chacun de leurs changements.

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

FocusScope {
    id: recommande

    // Le volet (Demarrer.qml) ; Item, car il contient lui-même ce type
    property Item demarrer: null
    // Liste de toutes les applications (« KICKER_ALL_MODEL ») et documents
    // récents
    property QtObject applications: null
    property QtObject documents: null
    readonly property alias vue: vue
    readonly property alias count: vue.count
    readonly property int maximum: Mesures.recommandeColonnes * Mesures.recommandeRangees
    property var entrees: []

    signal sortieHaut()
    signal sortieBas()

    implicitWidth: Mesures.recommandeColonnes * Mesures.recommandeLargeur
    implicitHeight: Mesures.recommandeRangees * Mesures.recommandeHauteur

    function lire(modele: QtObject, ligne: int, role: string): var {
        const numero = modele.KItemModels.KRoleNames.role(role);
        return numero < 0 ? undefined : modele.data(modele.index(ligne, 0), numero);
    }

    function reconstruire(): void {
        const liste = [];
        const applications = recommande.applications;
        if (applications) {
            for (let i = 0; i < applications.count && liste.length < maximum; ++i) {
                if (lire(applications, i, "isNewlyInstalled") === true) {
                    liste.push({ modele: applications, ligne: i, detail: "Ajoutée récemment" });
                }
            }
        }
        const documents = recommande.documents;
        if (documents) {
            for (let i = 0; i < documents.count && liste.length < maximum; ++i) {
                liste.push({ modele: documents, ligne: i, detail: lire(documents, i, "description") ?? "" });
            }
        }
        entrees = liste;
    }

    // Plusieurs changements de suite ne refont la liste qu'une fois
    Timer {
        id: retard
        interval: 0
        onTriggered: recommande.reconstruire()
    }
    onApplicationsChanged: retard.restart()
    onDocumentsChanged: retard.restart()
    Component.onCompleted: retard.restart()

    Connections {
        target: recommande.applications
        ignoreUnknownSignals: true
        function onCountChanged() { retard.restart(); }
        function onModelReset() { retard.restart(); }
        function onDataChanged() { retard.restart(); }
    }
    Connections {
        target: recommande.documents
        ignoreUnknownSignals: true
        function onCountChanged() { retard.restart(); }
        function onModelReset() { retard.restart(); }
        function onDataChanged() { retard.restart(); }
    }

    GridView {
        id: vue

        anchors.fill: parent
        model: recommande.entrees
        cellWidth: Mesures.recommandeLargeur
        cellHeight: Mesures.recommandeHauteur
        interactive: false
        focus: true
        activeFocusOnTab: count > 0
        currentIndex: count > 0 ? 0 : -1
        keyNavigationEnabled: false
        highlightFollowsCurrentItem: false
        reuseItems: false
        Accessible.role: Accessible.Table
        Accessible.name: "Recommandé"

        delegate: ElementListe {
            required property var modelData

            width: Mesures.recommandeLargeur
            height: Mesures.recommandeHauteur
            tailleIcone: Mesures.icone
            demarrer: recommande.demarrer
            modele: modelData.modele
            ligne: modelData.ligne
            nom: recommande.lire(modelData.modele, modelData.ligne, "display") ?? ""
            icone: recommande.lire(modelData.modele, modelData.ligne, "decoration") ?? null
            detail: modelData.detail
            favori: recommande.lire(modelData.modele, modelData.ligne, "favoriteId") ?? ""
            adresse: recommande.lire(modelData.modele, modelData.ligne, "url") ?? ""
            listeActions: recommande.lire(modelData.modele, modelData.ligne, "actionList") ?? null
            aActions: recommande.lire(modelData.modele, modelData.ligne, "hasActionList") ?? false
            selectionVisible: vue.activeFocus && (recommande.demarrer?.clavier ?? false)
            Accessible.role: Accessible.Cell
        }

        Keys.onMenuPressed: event => {
            const element = currentItem as Element;
            if (element !== null) {
                element.ouvrirMenu(undefined, undefined);
            }
        }

        Keys.onPressed: event => {
            if (recommande.demarrer) {
                recommande.demarrer.clavier = true;
            }
            const colonnes = Mesures.recommandeColonnes;
            switch (event.key) {
            case Qt.Key_Left:
                if (currentIndex % colonnes > 0) {
                    currentIndex -= 1;
                }
                event.accepted = true;
                break;
            case Qt.Key_Right:
                if (currentIndex % colonnes < colonnes - 1 && currentIndex < count - 1) {
                    currentIndex += 1;
                }
                event.accepted = true;
                break;
            case Qt.Key_Up:
                if (currentIndex < colonnes) {
                    recommande.sortieHaut();
                } else {
                    currentIndex -= colonnes;
                }
                event.accepted = true;
                break;
            case Qt.Key_Down:
                if (currentIndex + colonnes < count) {
                    currentIndex += colonnes;
                } else {
                    recommande.sortieBas();
                }
                event.accepted = true;
                break;
            case Qt.Key_Return:
            case Qt.Key_Enter:
            case Qt.Key_Space:
                (currentItem as Element)?.lancer();
                event.accepted = true;
                break;
            }
        }
    }

    // Rien à recommander pour l'instant
    Text {
        visible: vue.count === 0
        x: 2 * Mesures.recommandeRetrait
        width: parent.width - 4 * Mesures.recommandeRetrait
        y: Mesures.boutonRetrait
        text: "Vos fichiers récents et les applications que vous ajoutez apparaîtront ici."
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        font.family: Kirigami.Theme.defaultFont.family
        font.pixelSize: Mesures.texteLegende
        color: Kirigami.Theme.textColor
        opacity: Mesures.opaciteSecondaire
    }
}
