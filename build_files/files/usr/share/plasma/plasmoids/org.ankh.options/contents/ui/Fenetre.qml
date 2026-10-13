// Contenu de la fenêtre « Options d'Ankh » (D-046) : changer d'avis après
// l'installation, avec les mêmes cartes que la page « Choisissez vos outils »
// de l'assistant (module org.ankh.composants).
//
// La fenêtre lit le choix enregistré (ankh-options choix). « Appliquer », ou
// Entrée sur une case, lance « ankh-options-reglages appliquer <choix> » :
// le choix vaut pour toute la machine et demande le mot de passe d'un
// administrateur ; le menu et la barre de la session suivent. Quand une option
// est retirée, la fenêtre propose de supprimer ce qu'elle a téléchargé
// (« ankh-options-reglages supprimer <options> » : environnement de dev du
// compte, applications Gaming de la machine). Les commandes passent par le
// moteur « executable » de Plasma5Support, comme dans l'assistant.

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
    readonly property string commandeSupprimer: "/usr/libexec/ankh-options-reglages supprimer "

    property bool charge: false // choix enregistré lu
    property string choixEnregistre: ""
    property bool enCours: false
    property string activite: ""
    // Options retirées dont on propose de supprimer les téléchargements
    property var aSupprimer: []
    property string message: ""
    property int typeMessage: Kirigami.MessageType.Information
    property string texteFait: ""

    readonly property bool modifie: charge && liste.choix !== choixEnregistre
    readonly property bool question: aSupprimer.length > 0

    // Ce que chaque option a téléchargé, pour la question de suppression
    readonly property var telechargements: ({
        dev: "l'environnement de dev de votre compte",
        gaming: "les applications Gaming de la machine"
    })

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
        aSupprimer = [];
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
            liste.lire(sortie);
            choixEnregistre = liste.choix;
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
            const avant = choixEnregistre.split("_");
            choixEnregistre = commande.slice(commandeAppliquer.length);
            const apres = choixEnregistre.split("_");
            const phrases = [];
            if (!avant.includes("dev") && apres.includes("dev")) {
                phrases.push("VS Code est dans le menu et dans la barre : il se prépare à son premier lancement.");
            } else if (avant.includes("dev") && !apres.includes("dev")) {
                phrases.push("VS Code et les outils de dev ne sont plus dans le menu ni dans la barre.");
            }
            if (!avant.includes("gaming") && apres.includes("gaming")) {
                phrases.push("Steam et les autres outils Gaming sont dans le menu, et Steam dans la barre : chacun se prépare à son premier lancement.");
            } else if (avant.includes("gaming") && !apres.includes("gaming")) {
                phrases.push("Les outils Gaming ne sont plus dans le menu ni dans la barre.");
            }
            texteFait = "C'est fait. " + phrases.join(" ");
            // Lignes écrites par ankh-options-reglages
            const lignes = sortie.split("\n");
            let avertissements = 0;
            for (const ligne of lignes) {
                if (ligne.startsWith("avertissement : ")) {
                    texteFait += "\n" + ligne.slice("avertissement : ".length);
                    avertissements += 1;
                }
            }
            const ligneQuestion = lignes.find(ligne => ligne.startsWith("question : supprimer "));
            aSupprimer = ligneQuestion ? ligneQuestion.slice("question : supprimer ".length).trim().split(" ") : [];
            if (question) {
                const quoi = aSupprimer.map(option => telechargements[option]).join(" et ");
                informer(texteFait + "\nSupprimer aussi " + quoi + ", pour libérer leur place ? Vos fichiers, vos projets et vos jeux restent dans votre dossier personnel.", Kirigami.MessageType.Information);
            } else {
                informer(texteFait, avertissements > 0 ? Kirigami.MessageType.Warning : Kirigami.MessageType.Positive);
            }
            liste.prendreFocus();
        } else if (commande.startsWith(commandeSupprimer)) {
            if (code !== 0) {
                informer("La suppression n'a pas abouti.\n" + erreurs, Kirigami.MessageType.Error);
            } else {
                informer("C'est supprimé. Vos fichiers, vos projets et vos jeux sont toujours dans votre dossier personnel.", Kirigami.MessageType.Positive);
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
                    visible: fenetre.question
                    enabled: !fenetre.enCours
                    onTriggered: {
                        const options = fenetre.aSupprimer.join(" ");
                        fenetre.aSupprimer = [];
                        fenetre.informer("", Kirigami.MessageType.Information);
                        fenetre.lancer(fenetre.commandeSupprimer + options, "Suppression en cours…");
                    }
                },
                Kirigami.Action {
                    text: "Garder"
                    icon.name: "dialog-cancel"
                    visible: fenetre.question
                    enabled: !fenetre.enCours
                    onTriggered: {
                        fenetre.aSupprimer = [];
                        fenetre.informer(fenetre.texteFait + "\nTout reste en place : si vous recochez ces options, rien ne sera à télécharger de nouveau.", Kirigami.MessageType.Positive);
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
