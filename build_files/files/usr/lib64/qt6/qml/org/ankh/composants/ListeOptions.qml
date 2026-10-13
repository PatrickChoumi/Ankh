// Les options d'Ankh en cartes (D-046) : Complète, Simple (toujours
// incluse), Dev, Gaming et Hacking. Communes à la page « Choisissez vos
// outils » de l'assistant de premier démarrage et à la fenêtre « Options
// d'Ankh » : les deux montrent ainsi les mêmes cartes.

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

ColumnLayout {
    id: liste

    // Options proposées aujourd'hui : Dev et Gaming. Hacking arrive avec les
    // phases 6 et 7 (CLAUDE.md, §5) : elle est montrée, grisée.
    property bool dev: true
    property bool gaming: true

    // Complète : toutes les options proposées
    readonly property bool complete: dev && gaming

    // Choix au format de /usr/libexec/ankh-options : « simple », ou les
    // options séparées par « _ »
    readonly property string choix: {
        const options = [];
        if (dev) {
            options.push("dev");
        }
        if (gaming) {
            options.push("gaming");
        }
        return options.length > 0 ? options.join("_") : "simple";
    }

    // Coche les options d'après une liste enregistrée (« dev gaming… »)
    function lire(enregistrees: string): void {
        const options = enregistrees.trim().split(/\s+/);
        dev = options.includes("dev");
        gaming = options.includes("gaming");
    }

    // Le clavier commence à la première case, Complète
    function prendreFocus(): void {
        carteComplete.prendreFocus();
    }

    spacing: Kirigami.Units.largeSpacing

    CarteOption {
        id: carteComplete
        icone: "checkbox"
        titre: "Complète"
        detail: "Tout ce qui est proposé ci-dessous."
        coche: liste.complete
        onBasculee: coche => {
            liste.dev = coche;
            liste.gaming = coche;
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    CarteOption {
        icone: "applications-internet"
        titre: "Simple"
        mention: "Toujours incluse"
        detail: "Le bureau d'Ankh, Chrome, VLC et OnlyOffice."
        coche: true
        modifiable: false
    }

    CarteOption {
        icone: "ankh-vscode"
        titre: "Dev"
        detail: "VS Code, Java, Python, JavaScript, C et C++, bases de données. Se prépare au premier lancement de VS Code."
        coche: liste.dev
        onBasculee: coche => liste.dev = coche
    }

    CarteOption {
        icone: "applications-games"
        titre: "Gaming"
        detail: "Steam, Heroic, Lutris, Bottles, les outils du jeu, les manettes, la session console, Discord et OBS. Chacun se prépare à son premier lancement."
        coche: liste.gaming
        onBasculee: coche => liste.gaming = coche
    }

    CarteOption {
        icone: "security-high"
        titre: "Hacking"
        mention: "Bientôt"
        detail: "Kali dans un conteneur isolé, labs dans des VMs isolées."
        modifiable: false
    }
}
