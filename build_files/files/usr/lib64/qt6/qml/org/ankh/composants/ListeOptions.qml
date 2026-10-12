// Les options d'Ankh en cartes (D-046) : Complète, Simple (toujours
// incluse), Dev, Gaming et Hacking. Communes à la page « Choisissez vos
// outils » de l'assistant de premier démarrage et à la fenêtre « Options
// d'Ankh » : les deux montrent ainsi les mêmes cartes.

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

ColumnLayout {
    id: liste

    // Options proposées aujourd'hui. Gaming et Hacking arrivent avec les
    // phases 5 à 7 (CLAUDE.md, §5) : elles sont montrées, grisées.
    property bool dev: true

    // Choix au format de /usr/libexec/ankh-options : « simple », ou les
    // options séparées par « _ »
    readonly property string choix: dev ? "dev" : "simple"

    // Le clavier commence à la première case, Complète
    function prendreFocus(): void {
        complete.prendreFocus();
    }

    spacing: Kirigami.Units.largeSpacing

    CarteOption {
        id: complete
        icone: "checkbox"
        titre: "Complète"
        detail: "Tout ce qui est proposé ci-dessous."
        coche: liste.dev
        onBasculee: coche => liste.dev = coche
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
        mention: "Bientôt"
        detail: "Steam et les autres lanceurs, les manettes, le mode console, Discord et OBS."
        modifiable: false
    }

    CarteOption {
        icone: "security-high"
        titre: "Hacking"
        mention: "Bientôt"
        detail: "Kali dans un conteneur isolé, labs dans des VMs isolées."
        modifiable: false
    }
}
