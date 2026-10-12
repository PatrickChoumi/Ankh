// Page « Bienvenue dans Ankh » de l'assistant de premier démarrage (D-037).
// Ajoutée par la méthode prévue par KDE pour les distributions, sans toucher
// au programme (docs/CUSTOM_MODULES.md de https://invent.kde.org/plasma/plasma-setup).
// Elle vient en premier, juste après « Begin Setup » (poids -1 ; langue : 0) :
// elle compense le titre « Welcome to Plasma Desktop », écrit en dur.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasmasetup.components as PlasmaSetupComponents

PlasmaSetupComponents.SetupModule {
    id: root

    nextEnabled: true

    // Le titre « Bienvenue dans Ankh » est affiché par l'assistant, au-dessus
    // de la page (nom du module, metadata.json) : il n'est pas répété ici.

    contentItem: ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Kirigami.Units.gridUnit * 6
            implicitHeight: Kirigami.Units.gridUnit * 6
            source: "ankh-logo"
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: "Votre système pour coder, jouer et explorer la cybersécurité."
        }

        Repeater {
            model: [
                {
                    icone: "system-software-update",
                    texte: "Les mises à jour arrivent dans Discover. Rien ne s'installe sans vous, et elles s'appliquent au redémarrage que vous choisissez."
                },
                {
                    icone: "ankh-vscode",
                    texte: "Vous choisissez ensuite vos outils : Dev aujourd'hui, Gaming et Hacking bientôt. Chacun se prépare au premier clic."
                },
                {
                    icone: "edit-undo",
                    texte: "Une mise à jour ne vous plaît pas ? La version précédente est gardée : vous pouvez y revenir."
                }
            ]

            delegate: RowLayout {
                required property var modelData

                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Icon {
                    Layout.alignment: Qt.AlignTop
                    implicitWidth: Kirigami.Units.iconSizes.medium
                    implicitHeight: Kirigami.Units.iconSizes.medium
                    source: modelData.icone
                }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: modelData.texte
                }
            }
        }
    }
}
