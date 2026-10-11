/*
    SPDX-License-Identifier: GPL-2.0-or-later

    Page « Raccourcis utiles » de l'accueil de KDE (Welcome Center), ajoutée
    par Ankh (D-042) avec la méthode prévue par KDE (README.md de
    https://invent.kde.org/plasma/plasma-welcome, « Extending Welcome Center
    with custom pages »). Ce sont les raccourcis par défaut de KDE, vérifiés
    dans leurs sources (DECISIONS.md, D-042) : Ankh n'en change aucun.
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.welcome as Welcome

Welcome.Page {
    id: root

    heading: "Raccourcis utiles"
    description: "Quelques raccourcis pour aller plus vite, partout dans Ankh. « Windows » est la touche au logo de Windows de ton clavier. Chacun se change dans la Configuration du système, à la page Raccourcis."

    // Pour chaque raccourci : ses variantes, chacune étant une suite de touches.
    readonly property var raccourcis: [
        { variantes: [["Windows"]], action: "Ouvrir le menu des applications" },
        { variantes: [["Alt", "Espace"]], action: "Chercher une application, un fichier ou faire un calcul" },
        { variantes: [["Windows", "W"]], action: "Voir toutes les fenêtres ouvertes" },
        { variantes: [["Windows", "←"], ["Windows", "→"]], action: "Ranger la fenêtre sur une moitié de l'écran" },
        { variantes: [["Windows", "E"]], action: "Ouvrir tes fichiers" },
        { variantes: [["Ctrl", "Alt", "T"]], action: "Ouvrir le terminal" },
        { variantes: [["Windows", "V"]], action: "Retrouver ce que tu as copié" },
        { variantes: [["Impr. écran"], ["Windows", "Maj", "S"]], action: "Faire une capture d'écran" },
        { variantes: [["Windows", "."]], action: "Choisir un émoji" },
        { variantes: [["Windows", "L"]], action: "Verrouiller l'écran" }
    ]

    // Une touche du clavier, dessinée comme une touche
    component Touche: Rectangle {
        property alias text: etiquette.text

        implicitHeight: etiquette.implicitHeight + Kirigami.Units.smallSpacing * 2
        implicitWidth: Math.max(etiquette.implicitWidth + Kirigami.Units.largeSpacing * 2, implicitHeight)
        radius: Kirigami.Units.cornerRadius
        color: Kirigami.Theme.alternateBackgroundColor
        border.width: 1
        border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.25)

        QQC2.Label {
            id: etiquette
            anchors.centerIn: parent
            font.weight: Font.DemiBold
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width, Kirigami.Units.gridUnit * 36)
        spacing: Kirigami.Units.largeSpacing

        Repeater {
            model: root.raccourcis

            delegate: RowLayout {
                id: ligne

                required property var modelData

                Layout.fillWidth: true
                spacing: Kirigami.Units.gridUnit

                // Les touches, alignées à droite d'une colonne de largeur fixe
                RowLayout {
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 18
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 18
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    spacing: Kirigami.Units.smallSpacing

                    Item {
                        Layout.fillWidth: true
                    }

                    Repeater {
                        model: ligne.modelData.variantes

                        delegate: RowLayout {
                            id: variante

                            required property var modelData
                            required property int index

                            spacing: Kirigami.Units.smallSpacing

                            QQC2.Label {
                                visible: variante.index > 0
                                text: "ou"
                                opacity: 0.7
                            }

                            Repeater {
                                model: variante.modelData

                                delegate: RowLayout {
                                    id: touche

                                    required property string modelData
                                    required property int index

                                    spacing: Kirigami.Units.smallSpacing

                                    QQC2.Label {
                                        visible: touche.index > 0
                                        text: "+"
                                        opacity: 0.7
                                    }

                                    Touche {
                                        text: touche.modelData
                                    }
                                }
                            }
                        }
                    }
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: ligne.modelData.action
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
