// Sonde d'Alt+Tab d'Ankh (D-052, lot 7a), lancée hors écran à la
// construction par verifier-alttab.sh, à côté d'une copie du paquet
// (dossier « paquet »). Le module org.kde.kwin n'existe que dans KWin : la
// sonde crée donc le sélecteur (Selecteur.qml) avec de fausses fenêtres,
// aux rôles du modèle de KWin 6.7 (src/tabbox/clientmodel.cpp : caption,
// icon, windowId, closeable), et des rectangles pour vignettes. Elle vérifie
// la disposition (une rangée pour quatre fenêtres, plusieurs pour vingt,
// toujours dans l'écran) et les touches fléchées. Les messages passent par
// console.warn : console.log est filtré par Qt de Fedora.

import QtQuick

import "paquet/contents/ui" as Ankh

Item {
    id: sonde

    property var erreurs: []
    property var choix: []

    width: 1280
    height: 800

    function exiger(condition: bool, message: string): void {
        if (!condition) {
            erreurs.push(message);
        }
    }

    Component {
        id: vignetteFactice
        Rectangle {
            property var fenetre
            color: "#406080"
        }
    }

    ListModel {
        id: quatre
        ListElement { caption: "Documents — Dolphin"; icon: "system-file-manager"; windowId: 1; closeable: true }
        ListElement { caption: "Ankh — Google Chrome"; icon: "google-chrome"; windowId: 2; closeable: true }
        ListElement { caption: "Konsole"; icon: "utilities-terminal"; windowId: 3; closeable: true }
        ListElement { caption: "Configuration du système"; icon: "preferences-system"; windowId: 4; closeable: false }
    }

    ListModel {
        id: vingt
    }

    ListModel {
        id: aucune
    }

    Ankh.Selecteur {
        id: selecteur
        modele: quatre
        courant: 1
        largeurMax: Math.round(sonde.width * 0.9)
        hauteurMax: Math.round(sonde.height * 0.8)
        rapportEcran: sonde.width / sonde.height
        vignette: vignetteFactice
        onChoisi: index => sonde.choix.push(index)
    }

    Ankh.Selecteur {
        id: plein
        y: 400
        modele: vingt
        largeurMax: Math.round(sonde.width * 0.9)
        hauteurMax: Math.round(sonde.height * 0.8)
        rapportEcran: sonde.width / sonde.height
        vignette: vignetteFactice
    }

    Ankh.Selecteur {
        id: vide
        modele: aucune
        vignette: vignetteFactice
    }

    Component.onCompleted: {
        for (let i = 0; i < 20; i++) {
            vingt.append({ caption: "Fenêtre " + (i + 1), icon: "application-x-executable", windowId: 100 + i, closeable: true });
        }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: sonde.verifier()
    }

    function verifier(): void {
        // Quatre fenêtres : une rangée, vignettes entre 96 et 160 de haut
        exiger(selecteur.nombre === 4 && selecteur.colonnes === 4 && selecteur.rangees === 1,
            "quatre fenêtres : " + selecteur.colonnes + " colonnes, " + selecteur.rangees + " rangées");
        exiger(selecteur.hauteurVignette >= 96 && selecteur.hauteurVignette <= 160,
            "vignette de " + selecteur.hauteurVignette + " de haut");
        exiger(selecteur.width <= selecteur.largeurMax && selecteur.height <= selecteur.hauteurMax,
            "sélecteur de " + selecteur.width + "×" + selecteur.height + " hors de l'écran");
        // Vingt fenêtres : plusieurs rangées, toujours dans l'écran
        exiger(plein.nombre === 20 && plein.colonnes * plein.rangees >= 20 && plein.rangees > 1,
            "vingt fenêtres : " + plein.colonnes + " colonnes, " + plein.rangees + " rangées");
        exiger(plein.width <= plein.largeurMax && plein.height <= plein.hauteurMax,
            "sélecteur plein de " + plein.width + "×" + plein.height + " hors de l'écran");
        // Aucune fenêtre : le message
        exiger(vide.nombre === 0 && vide.width === 320 && vide.height === 120, "sélecteur vide de " + vide.width + "×" + vide.height);
        // Flèches : droite, gauche, et le tour par la gauche depuis la première
        selecteur.deplacer(1);
        selecteur.deplacer(-1);
        selecteur.courant = 0;
        selecteur.deplacer(-1);
        exiger(JSON.stringify(sonde.choix) === JSON.stringify([2, 0, 3]), "flèches : " + JSON.stringify(sonde.choix));

        if (erreurs.length > 0) {
            for (const erreur of erreurs) {
                console.warn("SONDE ÉCHEC : " + erreur);
            }
            Qt.exit(1);
        } else {
            console.warn("SONDE OK : quatre fenêtres en " + selecteur.width + "×" + selecteur.height + " (vignettes de "
                + selecteur.largeurVignette + "×" + selecteur.hauteurVignette + "), vingt en " + plein.colonnes + "×"
                + plein.rangees + " dans " + plein.width + "×" + plein.height);
            Qt.exit(0);
        }
    }
}
