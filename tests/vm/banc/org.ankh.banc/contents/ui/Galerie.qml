// Galerie des contrôles d'Ankh (D-052, lot 0) : chaque contrôle, comme dans
// une application de KDE en QML, à comparer à ceux de Windows 11.
//
// À gauche, la galerie, pour les captures. À droite, une zone de mesure sur
// fond noir : le banc y lit les coins des contrôles sur l'image.
// Trois secondes après l'ouverture, la galerie écrit ses mesures dans le
// journal de la session (console.warn, seul niveau gardé par Fedora) :
//   ANKH-BANC <mesure>=<valeur>             tailles données par le style
//   ANKH-BANC-PLACE <nom> <x> <y> <l> <h>  place d'un contrôle de la zone
//                                          de mesure, dans la fenêtre
//   ANKH-BANC-FIN                           fin des mesures
// Les identifiants des mesures sont ceux de build_files/interface/jetons.toml.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Item {
    id: galerie

    // plasmawindowed ouvre la fenêtre à cette taille (plasmawindowedview.cpp)
    Layout.minimumWidth: Kirigami.Units.gridUnit * 44
    Layout.minimumHeight: Kirigami.Units.gridUnit * 30

    // Taille en pixels d'une police : les polices de KDE sont réglées en
    // points, à 96 points par pouce sous Wayland (l'échelle de l'écran
    // s'applique ensuite).
    function enPixels(police: var): real {
        if (police.pixelSize > 0) {
            return police.pixelSize;
        }
        return Math.round(police.pointSize * 96 / 72 * 100) / 100;
    }

    // Une mesure impossible (élément absent du style, par exemple) est
    // signalée « ? », sans arrêter les suivantes.
    function signaler(mesure: string, lire: var): void {
        let valeur = "?";
        try {
            valeur = lire();
        } catch (erreur) {
            console.warn("ANKH-BANC-ERREUR " + mesure + " : " + erreur);
        }
        console.warn("ANKH-BANC " + mesure + "=" + valeur);
    }

    function placer(nom: string, objet: Item): void {
        const p = objet.mapToItem(null, 0, 0);
        console.warn("ANKH-BANC-PLACE " + nom + " " + Math.round(p.x) + " " + Math.round(p.y)
                     + " " + Math.round(objet.width) + " " + Math.round(objet.height));
    }

    function mesurer(): void {
        // Police vraiment affichée (fontInfo), et non celle demandée : une
        // police absente serait remplacée sans bruit
        signaler("police.famille", () => texteCorps.fontInfo.family);
        signaler("police.corps.px", () => enPixels(Kirigami.Theme.defaultFont));
        signaler("police.legende.px", () => enPixels(Kirigami.Theme.smallFont));
        signaler("police.corps.interligne", () => corps.height);
        signaler("kirigami.rayon", () => Kirigami.Units.cornerRadius);
        signaler("kirigami.unite", () => Kirigami.Units.gridUnit);
        signaler("controle.bouton.hauteur", () => boutonMesure.implicitHeight);
        signaler("controle.champ.hauteur", () => champMesure.implicitHeight);
        signaler("controle.liste_deroulante.hauteur", () => liste.implicitHeight);
        signaler("controle.case.taille", () => caseACocher.indicator.width);
        signaler("controle.case.hauteur", () => caseACocher.implicitHeight);
        signaler("controle.radio.taille", () => radio.indicator.width);
        signaler("controle.interrupteur.largeur", () => interrupteur.indicator.width);
        signaler("controle.interrupteur.hauteur", () => interrupteur.indicator.height);
        signaler("controle.curseur.poignee", () => curseur.handle.width);
        // La barre dessinée par le style : le contrôle de KDE ajoute 8 px de
        // marge au-dessus et au-dessous (topInset, bottomInset)
        signaler("controle.progression.hauteur", () => progression.implicitBackgroundHeight);
        signaler("controle.defilement.largeur", () => defilement.implicitWidth);
        signaler("controle.liste.hauteur", () => element.implicitHeight);
        signaler("controle.menu.element.hauteur", () => elementMenu.implicitHeight);
        signaler("controle.infobulle.px", () => enPixels(bulle.font));
        // Diagnostic : l'élément du style qui dessine le fond d'un bouton
        console.warn("ANKH-BANC-STYLE fond du bouton : " + boutonMesure.background);
        placer("bouton", boutonMesure);
        placer("champ", champMesure);
        console.warn("ANKH-BANC-FIN");
    }

    FontMetrics {
        id: corps
        font: Kirigami.Theme.defaultFont
    }

    Text {
        id: texteCorps
        visible: false
        font: Kirigami.Theme.defaultFont
        text: "Ankh"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Kirigami.Units.gridUnit
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Heading {
                text: "Galerie d'Ankh"
                level: 1
            }
            Label {
                text: "Les contrôles d'Ankh, à comparer à ceux de Windows 11 (D-052)."
                opacity: 0.7
            }
            RowLayout {
                spacing: Kirigami.Units.smallSpacing * 2
                Button {
                    text: "Appliquer"
                    highlighted: true
                }
                Button {
                    text: "Annuler"
                }
                ToolButton {
                    icon.name: "configure"
                }
                ToolButton {
                    icon.name: "edit-find"
                }
            }
            RowLayout {
                spacing: Kirigami.Units.gridUnit
                CheckBox {
                    id: caseACocher
                    text: "Case à cocher"
                    checked: true
                }
                CheckBox {
                    text: "Décochée"
                }
                RadioButton {
                    id: radio
                    text: "Choix"
                    checked: true
                }
                Switch {
                    id: interrupteur
                    text: "Interrupteur"
                    checked: true
                }
            }
            RowLayout {
                spacing: Kirigami.Units.smallSpacing * 2
                TextField {
                    placeholderText: "Rechercher un paramètre"
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 14
                }
                ComboBox {
                    id: liste
                    model: ["Sombre", "Clair", "Automatique"]
                }
                SpinBox {
                    value: 12
                }
            }
            RowLayout {
                spacing: Kirigami.Units.gridUnit
                Slider {
                    id: curseur
                    value: 0.6
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                }
                ProgressBar {
                    id: progression
                    value: 0.4
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                }
            }
            TabBar {
                TabButton {
                    text: "Général"
                }
                TabButton {
                    text: "Apparence"
                }
                TabButton {
                    text: "Avancé"
                }
            }
            Frame {
                Layout.fillWidth: true
                padding: 0
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    ItemDelegate {
                        id: element
                        text: "Système"
                        icon.name: "computer"
                        highlighted: true
                        Layout.fillWidth: true
                    }
                    ItemDelegate {
                        text: "Personnalisation"
                        icon.name: "preferences-desktop-theme"
                        Layout.fillWidth: true
                    }
                    ItemDelegate {
                        text: "Applications"
                        icon.name: "applications-all"
                        Layout.fillWidth: true
                    }
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }

        // Zone de mesure : fond noir, comme le fond d'écran des mesures du
        // banc, pour lire les coins des contrôles sur l'image.
        Rectangle {
            color: "black"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 12
            Layout.fillHeight: true

            Button {
                id: boutonMesure
                text: "Bouton"
                x: 24
                y: 24
            }
            TextField {
                id: champMesure
                text: "Champ"
                x: 24
                y: boutonMesure.y + boutonMesure.height + 24
                width: Kirigami.Units.gridUnit * 8
            }
            ScrollBar {
                id: defilement
                orientation: Qt.Vertical
                policy: ScrollBar.AlwaysOn
                size: 0.3
                position: 0.2
                x: 24
                y: champMesure.y + champMesure.height + 24
                height: Kirigami.Units.gridUnit * 6
            }
        }
    }

    // Mesurés sans être affichés
    Menu {
        id: menu
        MenuItem {
            id: elementMenu
            text: "Copier"
        }
    }
    ToolTip {
        id: bulle
        text: "Infobulle"
    }

    Timer {
        interval: 3000
        running: true
        onTriggered: galerie.mesurer()
    }
}
