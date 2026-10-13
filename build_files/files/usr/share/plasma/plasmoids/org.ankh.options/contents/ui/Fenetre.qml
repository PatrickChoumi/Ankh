// Contenu de la fenêtre « Options d'Ankh » (D-046) : changer d'avis après
// l'installation, avec les mêmes cartes que la page « Choisissez vos outils »
// de l'assistant (module org.ankh.composants).
//
// La fenêtre lit le choix enregistré (ankh-options choix). « Appliquer », ou
// Entrée sur une case, lance « ankh-options-reglages appliquer <choix> » :
// le choix vaut pour toute la machine et demande le mot de passe d'un
// administrateur ; le menu et la barre de la session suivent. Quand Dev est
// retirée, la fenêtre propose de supprimer l'environnement de dev du compte
// (ankh-dev supprimer). Les commandes passent par le moteur « executable » de
// Plasma5Support, comme dans l'assistant.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

import org.ankh.composants as Ankh

Item {
    id: fenetre

    // plasmawindowed ouvre la fenêtre à cette taille (plasmawindowedview.cpp)
    Layout.minimumWidth: Kirigami.Units.gridUnit * 36
    Layout.minimumHeight: Kirigami.Units.gridUnit * 34

    readonly property string commandeChoix: "/usr/libexec/ankh-options choix"
    readonly property string commandeAppliquer: "/usr/libexec/ankh-options-reglages appliquer "
    readonly property string commandeSupprimerDev: "/usr/libexec/ankh-dev supprimer"

    property bool charge: false // choix enregistré lu
    property bool devEnregistre: false
    property bool enCours: false
    property string activite: ""
    property bool questionDev: false
    property string message: ""
    property int typeMessage: Kirigami.MessageType.Information
    property string texteFait: ""

    readonly property bool modifie: charge && liste.dev !== devEnregistre

    function lancer(commande: string, texte: string): void {
        enCours = true;
        activite = texte;
        executable.connectSource(commande);
    }

    function informer(texte: string, type: int): void {
        message = texte;
        typeMessage = type;
    }

    function appliquer(): void {
        if (!modifie || enCours) {
            return;
        }
        questionDev = false;
        informer("", Kirigami.MessageType.Information);
        lancer(commandeAppliquer + liste.choix, "Application de votre choix…");
    }

    function fermer(): void {
        fenetre.Window.window.close();
    }

    function resultat(commande: string, code: int, sortie: string, erreurs: string): void {
        if (commande === commandeChoix) {
            if (code !== 0) {
                informer("Le choix enregistré n'a pas pu être lu.\n" + erreurs, Kirigami.MessageType.Error);
                return;
            }
            devEnregistre = (" " + sortie.trim() + " ").includes(" dev ");
            liste.dev = devEnregistre;
            charge = true;
            liste.prendreFocus();
        } else if (commande.startsWith(commandeAppliquer)) {
            // Codes de sortie de pkexec : 126, fenêtre du mot de passe fermée ;
            // 127, autorisation refusée (pkexec(1))
            if (code !== 0) {
                if (code === 126) {
                    informer("Le mot de passe n'a pas été donné : rien n'a changé.", Kirigami.MessageType.Warning);
                } else if (code === 127) {
                    informer("Votre choix n'a pas été appliqué : rien n'a changé. Il faut le mot de passe d'un administrateur de cette machine.", Kirigami.MessageType.Error);
                } else {
                    informer("Votre choix n'a pas été appliqué : rien n'a changé.\n" + erreurs, Kirigami.MessageType.Error);
                }
                liste.prendreFocus();
                return;
            }
            devEnregistre = commande.slice(commandeAppliquer.length).split("_").includes("dev");
            texteFait = devEnregistre
                ? "C'est fait. VS Code est dans le menu et dans la barre : il se prépare à son premier lancement."
                : "C'est fait. VS Code et les outils de dev ne sont plus dans le menu ni dans la barre.";
            // Lignes écrites par ankh-options-reglages
            const lignes = sortie.split("\n");
            let avertissements = 0;
            for (const ligne of lignes) {
                if (ligne.startsWith("avertissement : ")) {
                    texteFait += "\n" + ligne.slice("avertissement : ".length);
                    avertissements += 1;
                }
            }
            questionDev = lignes.includes("question : supprimer-dev");
            if (questionDev) {
                informer(texteFait + "\nSupprimer aussi l'environnement de dev de votre compte, pour libérer sa place ? Vos fichiers et vos projets restent dans votre dossier personnel.", Kirigami.MessageType.Information);
            } else {
                informer(texteFait, avertissements > 0 ? Kirigami.MessageType.Warning : Kirigami.MessageType.Positive);
            }
            liste.prendreFocus();
        } else if (commande === commandeSupprimerDev) {
            if (code !== 0) {
                informer("L'environnement de dev n'a pas pu être supprimé.\n" + erreurs, Kirigami.MessageType.Error);
            } else {
                informer("L'environnement de dev est supprimé. Vos fichiers et vos projets sont toujours dans votre dossier personnel.", Kirigami.MessageType.Positive);
            }
            liste.prendreFocus();
        }
    }

    Component.onCompleted: lancer(commandeChoix, "Lecture de votre choix…")

    Keys.onEscapePressed: fermer()

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            disconnectSource(source);
            fenetre.enCours = false;
            const code = data["exit code"] === undefined ? -1 : data["exit code"];
            fenetre.resultat(source, code, String(data["stdout"] || ""), String(data["stderr"] || "").trim());
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
    }

    // plasmawindowed propose un menu au clic droit : il serait vide ici
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit
        spacing: Kirigami.Units.largeSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                Layout.alignment: Qt.AlignTop
                implicitWidth: Kirigami.Units.iconSizes.large
                implicitHeight: Kirigami.Units.iconSizes.large
                source: "ankh-logo"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    Layout.fillWidth: true
                    level: 1
                    text: "Choisissez vos outils"
                }
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    opacity: 0.8
                    text: "Ce qui est coché est installé pour toute la machine, ce qui ne l'est pas n'est pas installé. Il faut le mot de passe d'un administrateur."
                }
            }
        }

        ScrollView {
            id: defilement
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            Ankh.ListeOptions {
                id: liste
                width: defilement.availableWidth
                enabled: fenetre.charge && !fenetre.enCours

                // Entrée sur une case applique le choix, comme le bouton
                Keys.onReturnPressed: fenetre.appliquer()
                Keys.onEnterPressed: fenetre.appliquer()
            }
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: fenetre.message.length > 0
            type: fenetre.typeMessage
            text: fenetre.message
            actions: [
                Kirigami.Action {
                    text: "Supprimer"
                    icon.name: "edit-delete"
                    visible: fenetre.questionDev
                    enabled: !fenetre.enCours
                    onTriggered: {
                        fenetre.questionDev = false;
                        fenetre.informer("", Kirigami.MessageType.Information);
                        fenetre.lancer(fenetre.commandeSupprimerDev, "Suppression de l'environnement de dev…");
                    }
                },
                Kirigami.Action {
                    text: "Garder"
                    icon.name: "dialog-cancel"
                    visible: fenetre.questionDev
                    enabled: !fenetre.enCours
                    onTriggered: {
                        fenetre.questionDev = false;
                        fenetre.informer(fenetre.texteFait + "\nL'environnement de dev reste sur votre compte : VS Code le retrouvera si vous recochez Dev.", Kirigami.MessageType.Positive);
                    }
                }
            ]
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            BusyIndicator {
                visible: fenetre.enCours
                running: visible
                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                implicitHeight: Kirigami.Units.iconSizes.smallMedium
            }
            Label {
                visible: fenetre.enCours
                text: fenetre.activite
                opacity: 0.8
            }
            Item {
                Layout.fillWidth: true
            }
            Button {
                text: "Fermer"
                icon.name: "window-close"
                enabled: !fenetre.enCours
                onClicked: fenetre.fermer()
            }
            Button {
                text: "Appliquer"
                icon.name: "dialog-ok-apply"
                highlighted: true
                enabled: fenetre.modifie && !fenetre.enCours
                onClicked: fenetre.appliquer()
            }
        }
    }
}
