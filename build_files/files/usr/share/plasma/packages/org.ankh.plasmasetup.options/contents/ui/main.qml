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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

import org.kde.plasmasetup.components as PlasmaSetupComponents

PlasmaSetupComponents.SetupModule {
    id: root

    // Options proposées aujourd'hui. Gaming et Hacking arrivent avec les
    // phases 5 à 7 (CLAUDE.md, §5) : elles sont montrées, grisées.
    property bool dev: true

    // Choix au format du service : « simple », ou les options séparées par « _ »
    readonly property string choix: dev ? "dev" : "simple"
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

    // Une option : icône, nom, contenu, et sa case
    component Option: Rectangle {
        id: option

        property string icone
        property string titre
        property string detail
        property string mention: ""
        property bool coche: false
        property bool modifiable: true
        signal basculee(bool coche)

        Layout.fillWidth: true
        implicitHeight: ligne.implicitHeight + Kirigami.Units.largeSpacing * 2
        radius: Kirigami.Units.cornerRadius
        color: Kirigami.Theme.alternateBackgroundColor
        border.width: 1
        border.color: coche && modifiable
            ? Kirigami.Theme.highlightColor
            : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
        opacity: modifiable || coche ? 1 : 0.55

        // Toute la carte se clique ; la case, au-dessus, garde ses propres clics.
        MouseArea {
            anchors.fill: parent
            enabled: option.modifiable
            cursorShape: Qt.PointingHandCursor
            onClicked: option.basculee(!option.coche)
        }

        RowLayout {
            id: ligne
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: Kirigami.Units.iconSizes.medium
                source: option.icone
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Label {
                        text: option.titre
                        font.weight: Font.DemiBold
                    }
                    Label {
                        visible: option.mention.length > 0
                        text: option.mention
                        font: Kirigami.Theme.smallFont
                        opacity: 0.7
                    }
                }
                Label {
                    Layout.fillWidth: true
                    text: option.detail
                    wrapMode: Text.Wrap
                    opacity: 0.8
                }
            }

            CheckBox {
                Layout.alignment: Qt.AlignVCenter
                checked: option.coche
                enabled: option.modifiable
                Accessible.name: option.titre
                onToggled: {
                    option.basculee(checked);
                    checked = Qt.binding(() => option.coche);
                }
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

            Option {
                icone: "checkbox"
                titre: "Complète"
                detail: "Tout ce qui est proposé ci-dessous."
                coche: root.dev
                onBasculee: coche => root.dev = coche
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            Option {
                icone: "applications-internet"
                titre: "Simple"
                mention: "Toujours incluse"
                detail: "Le bureau d'Ankh, Chrome, VLC et OnlyOffice."
                coche: true
                modifiable: false
            }

            Option {
                icone: "ankh-vscode"
                titre: "Dev"
                detail: "VS Code, Java, Python, JavaScript, C et C++, bases de données. Se prépare au premier lancement de VS Code."
                coche: root.dev
                onBasculee: coche => root.dev = coche
            }

            Option {
                icone: "applications-games"
                titre: "Gaming"
                mention: "Bientôt"
                detail: "Steam, Heroic, Lutris, Bottles, les manettes."
                modifiable: false
            }

            Option {
                icone: "security-high"
                titre: "Hacking"
                mention: "Bientôt"
                detail: "Kali dans un conteneur isolé, labs dans des VMs isolées."
                modifiable: false
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
