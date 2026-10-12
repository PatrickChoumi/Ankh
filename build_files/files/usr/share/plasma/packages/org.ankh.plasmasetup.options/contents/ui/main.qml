// Page « Choisissez vos outils » de l'assistant de premier démarrage (D-046) :
// Simple (toujours incluse), Dev, Gaming, Hacking, et Complète qui coche tout.
// Ajoutée comme « Bienvenue dans Ankh », par la méthode prévue par KDE
// (docs/CUSTOM_MODULES.md de https://invent.kde.org/plasma/plasma-setup),
// juste après la langue (poids 1 ; langue : 0).
//
// La page n'applique rien elle-même : elle démarre le service
// ankh-options@<choix>, que le compte de l'assistant a le droit de démarrer
// (/usr/share/polkit-1/rules.d/50-ankh-options.rules). La commande passe par
// le moteur « executable » de Plasma5Support, celui des widgets de Plasma
// (src/dataengines/executable de https://invent.kde.org/plasma/plasma5support).
// Le choix est appliqué à l'affichage de la page, puis à chaque changement.
// Les cartes viennent du module org.ankh.composants
// (/usr/lib64/qt6/qml/org/ankh/composants), partagé avec la fenêtre
// « Options d'Ankh ».

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

import org.kde.plasmasetup.components as PlasmaSetupComponents

import org.ankh.composants as Ankh

PlasmaSetupComponents.SetupModule {
    id: root

    // Choix au format du service : « simple », ou les options séparées par « _ »
    readonly property string choix: liste.choix
    property string applique: ""
    property bool enCours: false
    property string erreur: ""

    nextEnabled: !enCours

    function appliquer(): void {
        if (enCours) {
            return; // relancé à la fin de la commande en cours, si le choix a changé
        }
        enCours = true;
        erreur = "";
        executable.connectSource("systemctl --no-ask-password start ankh-options@" + choix + ".service");
    }

    // Appelée par l'assistant quand la page s'affiche (src/qml/Wizard.qml)
    function onPageActivated(): void {
        appliquer();
    }

    onChoixChanged: appliquer()

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            disconnectSource(source);
            root.enCours = false;
            if (data["exit code"] !== 0) {
                root.erreur = "Votre choix n'a pas pu être enregistré. " + String(data["stderr"] || "").trim();
                return;
            }
            root.applique = source.replace(/^.*ankh-options@([a-z_]+)\.service$/, "$1");
            if (root.applique !== root.choix) {
                root.appliquer();
            }
        }
    }

    contentItem: ScrollView {
        id: defilement
        contentWidth: availableWidth

        ColumnLayout {
            width: defilement.availableWidth
            spacing: Kirigami.Units.largeSpacing

            Label {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: "Cochez ce que vous voulez installer. Ce qui n'est pas coché n'est pas installé. Vous pourrez changer d'avis à tout moment dans la Configuration du système, page « Options d'Ankh »."
            }

            // Les cartes, communes avec la fenêtre « Options d'Ankh »
            Ankh.ListeOptions {
                id: liste
                Layout.fillWidth: true
            }

            Kirigami.InlineMessage {
                Layout.fillWidth: true
                type: Kirigami.MessageType.Error
                visible: root.erreur.length > 0
                text: root.erreur
                actions: [
                    Kirigami.Action {
                        text: "Réessayer"
                        icon.name: "view-refresh"
                        onTriggered: root.appliquer()
                    }
                ]
            }
        }
    }
}
