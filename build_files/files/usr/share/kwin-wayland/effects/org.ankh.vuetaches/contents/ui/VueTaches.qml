/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Vue des tâches d'Ankh (D-052, lot 7b ; mon choix du 2026-10-23, « Comme
// Windows 11 ») : le bouton « Vue des tâches » de la barre montre les
// fenêtres ouvertes en vignettes au centre de l'écran, chaque rangée
// centrée, et les bureaux virtuels dans une bande en bas, avec « Nouveau
// bureau ». Chaque fenêtre a son icône et son
// titre au-dessus de sa vignette, comme dans Alt+Tab (lot 7a) : fond discret
// au survol, croix de fermeture, contour de sélection de WinUI au clavier.
// Survoler un bureau montre ses fenêtres ; le cliquer y passe.
//
// Ce fichier ne dépend pas de KWin : main.qml lui donne les fenêtres
// (objets Window de KWin : caption, icon, closeable, internalId), les
// bureaux (objets VirtualDesktop : id, name), la place libre de l'écran
// (sans la barre des tâches, qui reste visible) et les vignettes, pour que
// la construction puisse le créer et le vérifier hors écran avec de faux
// objets (build_files/plasma/vuetaches-sonde.qml).
//
// Mesures : coins, couleurs et contour de WinUI (module commun d'Ankh) ;
// tailles, espacements et voile observés sur Windows 11, sans image
// officielle mesurable, À VALIDER : fenêtres comme dans Alt+Tab (rembourrage
// de 8, titre de 24, vignette sous le titre à 4), espacées de 16, de 55 % de
// la hauteur libre au plus ; bureaux de 10 % de la hauteur de l'écran
// (56 à 108) ; voile de l'arrière-plan à 75 %.

import QtQuick

import org.kde.kirigami as Kirigami

import org.ankh.commun

FocusScope {
    id: vue

    // Fenêtres du bureau montré, la plus récente d'abord
    required property var fenetres
    // Bureaux virtuels, dans leur ordre
    required property var bureaux
    // Bureau en cours, et bureau dont les fenêtres sont montrées
    property var bureauCourant
    property var bureauMontre: bureauCourant
    property int bureauxMax: 20
    // Place libre de l'écran (sans la barre des tâches), dans l'écran
    property rect zone: Qt.rect(0, 0, width, height)
    property real rapportEcran: width / Math.max(1, height)
    // Vignette d'une fenêtre (reçoit « fenetre ») et aperçu d'un bureau
    // (reçoit « bureau »), créés avec ces propriétés déjà posées
    property Component vignette
    property Component apercuBureau

    signal fenetreActivee(var fenetre)
    signal fenetreFermee(var fenetre)
    signal bureauActive(var bureau)
    signal bureauSurvole(var bureau)
    signal bureauAjoute()
    signal bureauRetire(var bureau)
    signal fermer()

    // Fenêtres
    readonly property int remplissage: 8
    readonly property int hauteurTitre: 24
    readonly property int ecartTitre: 4
    readonly property int espacement: 16
    readonly property int margeFenetres: 24
    readonly property int vignetteMin: 48
    // Bureaux
    readonly property int hauteurApercu: Math.round(Math.max(56, Math.min(108, height * 0.1)))
    readonly property int largeurApercu: Math.round(hauteurApercu * rapportEcran)
    readonly property int largeurBureau: largeurApercu + 2 * remplissage
    readonly property int hauteurBureau: remplissage + hauteurTitre + ecartTitre + hauteurApercu + remplissage
    readonly property int margeBande: 8
    readonly property int hauteurBande: hauteurBureau + 2 * margeBande

    readonly property int nombre: fenetres ? fenetres.length : 0
    readonly property int nombreBureaux: bureaux ? bureaux.length : 0

    // Place des fenêtres : au-dessus de la bande des bureaux
    readonly property int largeurFenetres: Math.max(0, zone.width - 2 * margeFenetres)
    readonly property int hauteurFenetres: Math.max(0, zone.height - hauteurBande - 2 * margeFenetres)
    readonly property int vignetteMax: Math.round(hauteurFenetres * 0.55)

    // Le nombre de colonnes qui donne les plus grandes vignettes
    readonly property var disposition: {
        const n = Math.max(1, nombre);
        let meilleure = { colonnes: 1, rangees: n, hauteur: -1 };
        for (let c = 1; c <= n; c++) {
            const r = Math.ceil(n / c);
            const largeurCellule = (largeurFenetres - (c - 1) * espacement) / c;
            const hauteurCellule = (hauteurFenetres - (r - 1) * espacement) / r;
            const h = Math.min(hauteurCellule - 2 * remplissage - hauteurTitre - ecartTitre,
                (largeurCellule - 2 * remplissage) / rapportEcran, vignetteMax);
            if (h > meilleure.hauteur + 0.5) {
                meilleure = { colonnes: c, rangees: r, hauteur: h };
            }
        }
        meilleure.hauteur = Math.max(vignetteMin, Math.floor(meilleure.hauteur));
        return meilleure;
    }
    readonly property int colonnes: disposition.colonnes
    readonly property int rangees: disposition.rangees
    readonly property int hauteurVignette: disposition.hauteur
    readonly property int largeurVignette: Math.round(hauteurVignette * rapportEcran)
    readonly property int largeurElement: largeurVignette + 2 * remplissage
    readonly property int hauteurElement: remplissage + hauteurTitre + ecartTitre + hauteurVignette + remplissage
    readonly property int hauteurGrille: rangees * hauteurElement + (rangees - 1) * espacement

    // Sélection au clavier : la fenêtre ou le bureau choisi, et le contour
    // de WinUI seulement après une touche, comme dans Windows
    property int courant: 0
    property int bureauChoisi: 0
    property bool dansBureaux: false
    property bool clavier: false

    focus: true

    function deplacer(pas: int): void {
        clavier = true;
        if (dansBureaux) {
            // « Nouveau bureau » vient après le dernier bureau
            const total = nombreBureaux + (nombreBureaux < bureauxMax ? 1 : 0);
            bureauChoisi = Math.max(0, Math.min(total - 1, bureauChoisi + pas));
            if (bureauChoisi < nombreBureaux) {
                vue.bureauSurvole(bureaux[bureauChoisi]);
            }
            return;
        }
        if (nombre === 0) {
            return;
        }
        let index = courant + pas;
        if (Math.abs(pas) === 1) {
            index = (index + nombre) % nombre;
        } else {
            index = Math.max(0, Math.min(nombre - 1, index));
        }
        courant = index;
    }

    function valider(): void {
        if (dansBureaux) {
            if (bureauChoisi < nombreBureaux) {
                vue.bureauActive(bureaux[bureauChoisi]);
            } else {
                vue.bureauAjoute();
            }
        } else if (nombre > 0) {
            vue.fenetreActivee(fenetres[courant]);
        }
    }

    function supprimer(): void {
        if (dansBureaux) {
            if (bureauChoisi < nombreBureaux && nombreBureaux > 1) {
                vue.bureauRetire(bureaux[bureauChoisi]);
            }
        } else if (nombre > 0 && fenetres[courant].closeable) {
            vue.fenetreFermee(fenetres[courant]);
        }
    }

    function memeBureau(a, b): bool {
        return !!a && !!b && a.id === b.id;
    }

    // Place d'une fenêtre dans la vue (pour la sonde de la construction)
    function rectangleFenetre(index: int): rect {
        const element = repetiteur.itemAt(index);
        if (!element) {
            return Qt.rect(0, 0, 0, 0);
        }
        const coin = element.mapToItem(vue, 0, 0);
        return Qt.rect(coin.x, coin.y, element.width, element.height);
    }

    onNombreChanged: courant = Math.max(0, Math.min(courant, nombre - 1))
    onNombreBureauxChanged: bureauChoisi = Math.max(0, Math.min(bureauChoisi, nombreBureaux))

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            vue.fermer();
        } else if (event.key === Qt.Key_Left) {
            deplacer(-1);
        } else if (event.key === Qt.Key_Right) {
            deplacer(1);
        } else if (event.key === Qt.Key_Up && !dansBureaux) {
            deplacer(-colonnes);
        } else if (event.key === Qt.Key_Down && !dansBureaux) {
            if (courant + colonnes < nombre) {
                deplacer(colonnes);
            } else {
                clavier = true;
                dansBureaux = true;
            }
        } else if (event.key === Qt.Key_Up && dansBureaux) {
            clavier = true;
            dansBureaux = false;
        } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            clavier = true;
            dansBureaux = !dansBureaux;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            valider();
        } else if (event.key === Qt.Key_Delete) {
            clavier = true;
            supprimer();
        } else {
            return;
        }
        event.accepted = true;
    }

    Couleurs {
        id: couleurs
    }

    // Voile sur l'arrière-plan flou (main.qml), qui ferme la vue au clic
    Rectangle {
        anchors.fill: parent
        color: couleurs.sombre ? "#202020" : "#f3f3f3"
        opacity: 0.75
    }
    MouseArea {
        anchors.fill: parent
        onClicked: vue.fermer()
    }

    // Fenêtres, rangées centrées, au-dessus de la bande des bureaux
    Flickable {
        id: defilement
        x: vue.zone.x + vue.margeFenetres
        y: vue.zone.y + vue.margeFenetres
        width: vue.largeurFenetres
        height: vue.hauteurFenetres
        contentWidth: width
        contentHeight: Math.max(height, vue.hauteurGrille)
        interactive: vue.hauteurGrille > height
        clip: interactive
        boundsBehavior: Flickable.StopAtBounds

        // Un clic hors des fenêtres ferme aussi la vue
        MouseArea {
            width: defilement.contentWidth
            height: defilement.contentHeight
            onClicked: vue.fermer()
        }

        Repeater {
            id: repetiteur
            model: vue.fenetres

            delegate: Item {
                id: element

                required property int index
                required property var modelData
                readonly property var fenetre: modelData
                readonly property bool estCourant: vue.clavier && !vue.dansBureaux && index === vue.courant

                readonly property int rangee: Math.floor(index / vue.colonnes)
                readonly property int colonne: index % vue.colonnes
                readonly property int dansRangee: rangee === vue.rangees - 1 ? vue.nombre - vue.colonnes * (vue.rangees - 1) : vue.colonnes
                readonly property int largeurRangee: dansRangee * vue.largeurElement + (dansRangee - 1) * vue.espacement

                x: Math.round((defilement.width - largeurRangee) / 2) + colonne * (vue.largeurElement + vue.espacement)
                y: Math.max(0, Math.round((defilement.height - vue.hauteurGrille) / 2)) + rangee * (vue.hauteurElement + vue.espacement)
                width: vue.largeurElement
                height: vue.hauteurElement

                Accessible.name: fenetre.caption
                Accessible.role: Accessible.ListItem

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: element.estCourant || zone.containsMouse ? couleurs.discretSurvol : "transparent"
                }

                MouseArea {
                    id: zone
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.MiddleButton) {
                            if (element.fenetre.closeable) {
                                vue.fenetreFermee(element.fenetre);
                            }
                        } else {
                            vue.fenetreActivee(element.fenetre);
                        }
                    }
                }

                Row {
                    x: vue.remplissage
                    y: vue.remplissage
                    height: vue.hauteurTitre
                    spacing: 8
                    Kirigami.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16
                        source: element.fenetre.icon
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        // La place de la croix reste libre à droite
                        width: vue.largeurVignette - 16 - 8 - 24
                        text: element.fenetre.caption
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        font: Kirigami.Theme.smallFont
                        color: Kirigami.Theme.textColor
                    }
                }

                Item {
                    id: boiteVignette
                    x: vue.remplissage
                    y: vue.remplissage + vue.hauteurTitre + vue.ecartTitre
                    width: vue.largeurVignette
                    height: vue.hauteurVignette
                    Component.onCompleted: {
                        if (vue.vignette) {
                            vue.vignette.createObject(boiteVignette, { fenetre: element.fenetre });
                        }
                    }
                }

                BoutonDiscret {
                    visible: element.fenetre.closeable && (element.estCourant || zone.containsMouse)
                    anchors.right: parent.right
                    anchors.rightMargin: vue.remplissage - 4
                    y: vue.remplissage
                    width: 24
                    height: 24
                    icone: "window-close-symbolic"
                    infobulle: "Fermer"
                    onClique: vue.fenetreFermee(element.fenetre)
                }

                Contour {
                    visible: element.estCourant
                }
            }
        }
    }

    Text {
        x: vue.zone.x
        y: vue.zone.y
        width: vue.zone.width
        height: vue.zone.height - vue.hauteurBande
        visible: vue.nombre === 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "Aucune fenêtre ouverte"
        color: couleurs.texteSecondaire
    }

    // Bande des bureaux, en bas de la place libre
    Rectangle {
        id: bande
        x: vue.zone.x
        y: vue.zone.y + vue.zone.height - height
        width: vue.zone.width
        height: vue.hauteurBande
        color: couleurs.carte

        Rectangle {
            width: parent.width
            height: 1
            color: couleurs.separateur
        }

        // Un clic dans la bande, hors des bureaux, ne ferme pas la vue
        MouseArea {
            anchors.fill: parent
        }

        Flickable {
            id: defilementBureaux
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(rangeeBureaux.width, parent.width - 2 * vue.margeBande)
            x: Math.round((parent.width - width) / 2)
            height: vue.hauteurBureau
            contentWidth: rangeeBureaux.width
            contentHeight: height
            interactive: contentWidth > width
            clip: interactive
            boundsBehavior: Flickable.StopAtBounds

            Row {
                id: rangeeBureaux
                spacing: vue.espacement

                Repeater {
                    model: vue.bureaux

                    delegate: Item {
                        id: carte

                        required property int index
                        required property var modelData
                        readonly property var bureau: modelData
                        readonly property bool estCourant: vue.memeBureau(bureau, vue.bureauCourant)
                        readonly property bool estChoisi: vue.clavier && vue.dansBureaux && index === vue.bureauChoisi

                        width: vue.largeurBureau
                        height: vue.hauteurBureau

                        Accessible.name: bureau.name
                        Accessible.role: Accessible.ListItem

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: carte.estChoisi || zoneBureau.containsMouse ? couleurs.discretSurvol
                                : (carte.estCourant ? couleurs.discretAppui : "transparent")
                        }

                        MouseArea {
                            id: zoneBureau
                            anchors.fill: parent
                            hoverEnabled: true
                            onContainsMouseChanged: {
                                if (containsMouse) {
                                    vue.bureauSurvole(carte.bureau);
                                }
                            }
                            onClicked: vue.bureauActive(carte.bureau)
                        }

                        Text {
                            x: vue.remplissage
                            y: vue.remplissage
                            width: vue.largeurApercu - 24
                            height: vue.hauteurTitre
                            verticalAlignment: Text.AlignVCenter
                            text: carte.bureau.name
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            font: Kirigami.Theme.smallFont
                            color: Kirigami.Theme.textColor
                        }

                        Item {
                            id: boiteApercu
                            x: vue.remplissage
                            y: vue.remplissage + vue.hauteurTitre + vue.ecartTitre
                            width: vue.largeurApercu
                            height: vue.hauteurApercu
                            clip: true
                            Component.onCompleted: {
                                if (vue.apercuBureau) {
                                    vue.apercuBureau.createObject(boiteApercu, { bureau: carte.bureau });
                                }
                            }
                        }
                        // Bord de l'aperçu ; le bureau en cours, à l'accent
                        Rectangle {
                            x: boiteApercu.x
                            y: boiteApercu.y
                            width: boiteApercu.width
                            height: boiteApercu.height
                            radius: 4
                            color: "transparent"
                            border.width: carte.estCourant ? 2 : 1
                            border.color: carte.estCourant ? couleurs.accent : couleurs.bordControle
                        }

                        BoutonDiscret {
                            visible: vue.nombreBureaux > 1 && (carte.estChoisi || zoneBureau.containsMouse)
                            anchors.right: parent.right
                            anchors.rightMargin: vue.remplissage - 4
                            y: vue.remplissage
                            width: 24
                            height: 24
                            icone: "window-close-symbolic"
                            infobulle: "Fermer le bureau"
                            onClique: vue.bureauRetire(carte.bureau)
                        }

                        Contour {
                            visible: carte.estChoisi
                        }
                    }
                }

                // Nouveau bureau
                Item {
                    id: nouveau
                    visible: vue.nombreBureaux < vue.bureauxMax
                    readonly property bool estChoisi: vue.clavier && vue.dansBureaux && vue.bureauChoisi === vue.nombreBureaux
                    width: vue.largeurBureau
                    height: vue.hauteurBureau

                    Accessible.name: "Nouveau bureau"
                    Accessible.role: Accessible.Button

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: nouveau.estChoisi || zoneNouveau.containsMouse ? couleurs.discretSurvol : "transparent"
                    }
                    MouseArea {
                        id: zoneNouveau
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: vue.bureauAjoute()
                    }
                    Text {
                        x: vue.remplissage
                        y: vue.remplissage
                        height: vue.hauteurTitre
                        verticalAlignment: Text.AlignVCenter
                        text: "Nouveau bureau"
                        font: Kirigami.Theme.smallFont
                        color: Kirigami.Theme.textColor
                    }
                    Rectangle {
                        x: vue.remplissage
                        y: vue.remplissage + vue.hauteurTitre + vue.ecartTitre
                        width: vue.largeurApercu
                        height: vue.hauteurApercu
                        radius: 4
                        color: zoneNouveau.pressed ? couleurs.controleAppui : (zoneNouveau.containsMouse ? couleurs.controleSurvol : couleurs.controle)
                        border.width: 1
                        border.color: couleurs.bordControle
                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: "list-add-symbolic"
                            isMask: true
                            color: Kirigami.Theme.textColor
                        }
                    }
                    Contour {
                        visible: nouveau.estChoisi
                    }
                }
            }
        }
    }

    // Contour de sélection de WinUI : 2 px dehors, 1 px dedans, coins de 8.
    // Un composant en ligne ne voit pas les id du fichier : il a ses couleurs.
    component Contour: Item {
        anchors.fill: parent
        Couleurs {
            id: couleursContour
        }
        Rectangle {
            anchors.fill: parent
            radius: 8
            color: "transparent"
            border.width: 2
            border.color: couleursContour.focusExterieur
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: 6
            color: "transparent"
            border.width: 1
            border.color: couleursContour.focusInterieur
        }
    }
}
