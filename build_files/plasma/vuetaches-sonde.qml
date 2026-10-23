// Sonde de la vue des tâches d'Ankh (D-052, lot 7b), lancée hors écran à la
// construction par verifier-vuetaches.sh, à côté d'une copie du paquet
// (dossier « paquet »). Le module org.kde.kwin n'existe que dans KWin : la
// sonde crée donc la vue (VueTaches.qml) avec de faux objets, aux propriétés
// de KWin 6.7 (Window : caption, icon, closeable, internalId ;
// VirtualDesktop : id, name), sur un écran de 1280×800 dont la barre des
// tâches prend les 48 px du bas. Elle vérifie la disposition (une grande
// vignette pour une fenêtre, des rangées centrées, toujours dans la place
// libre), les vignettes et aperçus créés avec leur objet, et le clavier.
// Les messages passent par console.warn : console.log est filtré par Qt de
// Fedora.

import QtQuick

import "paquet/contents/ui" as Ankh

Item {
    id: sonde

    property var erreurs: []
    property var evenements: []
    property int vignettesSansFenetre: 0
    property int vignettesCreees: 0
    property int apercusCrees: 0

    width: 1280
    height: 800

    function exiger(condition: bool, message: string): void {
        if (!condition) {
            erreurs.push(message);
        }
    }

    function fenetres(n: int): var {
        const liste = [];
        for (let i = 0; i < n; i++) {
            liste.push({ caption: "Fenêtre " + (i + 1), icon: "application-x-executable", closeable: i !== 1, internalId: "f" + i });
        }
        return liste;
    }

    readonly property var bureaux: [{ id: "b1", name: "Bureau 1" }, { id: "b2", name: "Bureau 2" }]

    Component {
        id: vignetteFactice
        Rectangle {
            property var fenetre
            anchors.fill: parent
            color: "#406080"
            Component.onCompleted: {
                sonde.vignettesCreees++;
                if (!fenetre || !fenetre.internalId) {
                    sonde.vignettesSansFenetre++;
                }
            }
        }
    }

    Component {
        id: apercuFactice
        Rectangle {
            property var bureau
            anchors.fill: parent
            color: "#304050"
            Component.onCompleted: {
                if (bureau && bureau.id) {
                    sonde.apercusCrees++;
                }
            }
        }
    }

    // Un composant en ligne ne voit pas les id du fichier : chaque vue a
    // donc ses réglages
    Ankh.VueTaches {
        id: une
        fenetres: sonde.fenetres(1)
        width: sonde.width
        height: sonde.height
        bureaux: sonde.bureaux
        bureauCourant: sonde.bureaux[0]
        zone: Qt.rect(0, 0, 1280, 752)
        rapportEcran: 1280 / 800
        vignette: vignetteFactice
        apercuBureau: apercuFactice
    }
    Ankh.VueTaches {
        id: quatre
        fenetres: sonde.fenetres(4)
        width: sonde.width
        height: sonde.height
        bureaux: sonde.bureaux
        bureauCourant: sonde.bureaux[0]
        zone: Qt.rect(0, 0, 1280, 752)
        rapportEcran: 1280 / 800
        vignette: vignetteFactice
        apercuBureau: apercuFactice
        onFenetreActivee: fenetre => sonde.evenements.push("activee " + fenetre.internalId)
        onFenetreFermee: fenetre => sonde.evenements.push("fermee " + fenetre.internalId)
        onBureauSurvole: bureau => sonde.evenements.push("survole " + bureau.id)
        onBureauActive: bureau => sonde.evenements.push("bureau " + bureau.id)
        onBureauRetire: bureau => sonde.evenements.push("retire " + bureau.id)
        onBureauAjoute: sonde.evenements.push("ajoute")
    }
    Ankh.VueTaches {
        id: treize
        fenetres: sonde.fenetres(13)
        width: sonde.width
        height: sonde.height
        bureaux: sonde.bureaux
        bureauCourant: sonde.bureaux[0]
        zone: Qt.rect(0, 0, 1280, 752)
        rapportEcran: 1280 / 800
        vignette: vignetteFactice
        apercuBureau: apercuFactice
    }
    Ankh.VueTaches {
        id: quarante
        fenetres: sonde.fenetres(40)
        width: sonde.width
        height: sonde.height
        bureaux: sonde.bureaux
        bureauCourant: sonde.bureaux[0]
        zone: Qt.rect(0, 0, 1280, 752)
        rapportEcran: 1280 / 800
        vignette: vignetteFactice
        apercuBureau: apercuFactice
    }
    Ankh.VueTaches {
        id: aucune
        fenetres: []
        width: sonde.width
        height: sonde.height
        bureaux: sonde.bureaux
        bureauCourant: sonde.bureaux[0]
        zone: Qt.rect(0, 0, 1280, 752)
        rapportEcran: 1280 / 800
        vignette: vignetteFactice
        apercuBureau: apercuFactice
    }

    // Toutes les fenêtres dans la place libre (au-dessus de la bande des
    // bureaux, ou dans le défilement), chaque rangée centrée
    function verifierDisposition(vue: var, nom: string): void {
        const haut = vue.zone.y;
        const bas = vue.zone.y + vue.zone.height - vue.hauteurBande;
        const rangees = {};
        for (let i = 0; i < vue.nombre; i++) {
            const r = vue.rectangleFenetre(i);
            exiger(r.width > 0 && r.x >= vue.zone.x && r.x + r.width <= vue.zone.x + vue.zone.width,
                nom + " : fenêtre " + i + " hors de l'écran en largeur (" + r.x + ", " + r.width + ")");
            if (vue.hauteurGrille <= vue.hauteurFenetres) {
                exiger(r.y >= haut && r.y + r.height <= bas,
                    nom + " : fenêtre " + i + " hors de la place libre en hauteur (" + r.y + ", " + r.height + ")");
            }
            const cle = Math.round(r.y);
            rangees[cle] = rangees[cle] || { gauche: r.x, droite: r.x + r.width };
            rangees[cle].gauche = Math.min(rangees[cle].gauche, r.x);
            rangees[cle].droite = Math.max(rangees[cle].droite, r.x + r.width);
        }
        const centre = vue.zone.x + vue.zone.width / 2;
        for (const cle in rangees) {
            const milieu = (rangees[cle].gauche + rangees[cle].droite) / 2;
            exiger(Math.abs(milieu - centre) <= 1, nom + " : rangée en " + cle + " décentrée (milieu " + milieu + ")");
        }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: sonde.verifier()
    }

    function verifier(): void {
        // Une fenêtre : une seule vignette, de la plus grande taille
        exiger(une.colonnes === 1 && une.rangees === 1 && une.hauteurVignette === une.vignetteMax,
            "une fenêtre : " + une.colonnes + "×" + une.rangees + ", vignette de " + une.hauteurVignette + " (au plus " + une.vignetteMax + ")");
        verifierDisposition(une, "une fenêtre");
        // Quatre fenêtres : aucune colonne vide, et des vignettes au moins
        // aussi grandes que sur une seule rangée
        const enLigne = Math.floor(((quatre.largeurFenetres - 3 * quatre.espacement) / 4 - 2 * quatre.remplissage) / quatre.rapportEcran);
        exiger(quatre.nombre === 4 && quatre.colonnes * quatre.rangees >= 4 && (quatre.colonnes - 1) * quatre.rangees < 4
            && quatre.hauteurVignette >= enLigne,
            "quatre fenêtres : " + quatre.colonnes + "×" + quatre.rangees + ", vignette de " + quatre.hauteurVignette + " (" + enLigne + " sur une rangée)");
        verifierDisposition(quatre, "quatre fenêtres");
        // Treize : plusieurs rangées, la dernière centrée
        exiger(treize.rangees > 1 && treize.colonnes * treize.rangees >= 13, "treize fenêtres : " + treize.colonnes + "×" + treize.rangees);
        verifierDisposition(treize, "treize fenêtres");
        // Quarante : vignettes plus petites, toujours dans la largeur
        exiger(quarante.hauteurVignette >= quarante.vignetteMin && quarante.hauteurVignette < treize.hauteurVignette,
            "quarante fenêtres : vignette de " + quarante.hauteurVignette);
        verifierDisposition(quarante, "quarante fenêtres");
        // Aucune fenêtre : rien dans la grille
        exiger(aucune.nombre === 0, "aucune fenêtre : " + aucune.nombre);
        // Vignettes et aperçus créés avec leur objet
        exiger(vignettesCreees === 1 + 4 + 13 + 40 && vignettesSansFenetre === 0,
            vignettesCreees + " vignettes créées, " + vignettesSansFenetre + " sans fenêtre");
        exiger(apercusCrees === 5 * 2, apercusCrees + " aperçus de bureaux créés avec leur bureau");
        // Bande des bureaux : deux bureaux et « Nouveau bureau », dans l'écran
        exiger(quatre.hauteurApercu === 80 && quatre.largeurApercu === 128 && quatre.hauteurBande === 140,
            "bande des bureaux : aperçus de " + quatre.largeurApercu + "×" + quatre.hauteurApercu + ", bande de " + quatre.hauteurBande);

        // Clavier, fenêtres : droite, gauche, tour par la gauche, valider,
        // fermer (la deuxième ne se ferme pas)
        quatre.deplacer(1);
        exiger(quatre.courant === 1 && quatre.clavier, "flèche droite : fenêtre " + quatre.courant);
        quatre.supprimer();
        quatre.deplacer(-1);
        quatre.deplacer(-1);
        exiger(quatre.courant === 3, "tour par la gauche : fenêtre " + quatre.courant);
        quatre.valider();
        quatre.supprimer();
        // Clavier, bureaux : passer à la bande, droite, valider, fermer,
        // puis « Nouveau bureau »
        quatre.dansBureaux = true;
        quatre.deplacer(1);
        quatre.valider();
        quatre.supprimer();
        quatre.deplacer(1);
        quatre.valider();
        quatre.deplacer(1);
        exiger(quatre.bureauChoisi === 2, "bureaux : choix " + quatre.bureauChoisi + " après « Nouveau bureau »");
        const attendus = ["activee f3", "fermee f3", "survole b2", "bureau b2", "retire b2", "ajoute"];
        exiger(JSON.stringify(sonde.evenements) === JSON.stringify(attendus), "événements : " + JSON.stringify(sonde.evenements));

        if (erreurs.length > 0) {
            for (const erreur of erreurs) {
                console.warn("SONDE ÉCHEC : " + erreur);
            }
            Qt.exit(1);
        } else {
            console.warn("SONDE OK : une fenêtre en " + une.largeurVignette + "×" + une.hauteurVignette + ", quatre en "
                + quatre.colonnes + "×" + quatre.rangees + " (" + quatre.largeurVignette + "×" + quatre.hauteurVignette
                + "), treize en " + treize.colonnes + "×" + treize.rangees + ", quarante en " + quarante.colonnes + "×"
                + quarante.rangees + " (" + quarante.largeurVignette + "×" + quarante.hauteurVignette + "), bureaux de "
                + quatre.largeurApercu + "×" + quatre.hauteurApercu);
            Qt.exit(0);
        }
    }
}
