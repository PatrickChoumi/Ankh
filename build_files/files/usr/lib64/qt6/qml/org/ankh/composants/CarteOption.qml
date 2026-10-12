// Une option d'Ankh en carte (D-046) : icône, nom, contenu, et sa case.
// Toute la carte se clique ; la case garde ses propres clics et le clavier
// (Tab pour y aller, Espace pour cocher).

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Rectangle {
    id: carte

    property string icone
    property string titre
    property string detail
    property string mention: ""
    property bool coche: false
    property bool modifiable: true
    signal basculee(bool coche)

    readonly property bool cliquable: modifiable && enabled

    // Donne le clavier à la case de la carte
    function prendreFocus(): void {
        caseOption.forceActiveFocus();
    }

    Layout.fillWidth: true
    implicitHeight: ligne.implicitHeight + Kirigami.Units.largeSpacing * 2
    radius: Kirigami.Units.cornerRadius
    // Teinte légère au survol : la carte se clique
    color: survol.hovered && cliquable
        ? Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.alternateBackgroundColor, Kirigami.Theme.highlightColor, 0.08)
        : Kirigami.Theme.alternateBackgroundColor
    border.width: 1
    border.color: coche && modifiable
        ? Kirigami.Theme.highlightColor
        : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
    opacity: modifiable || coche ? 1 : 0.55

    Behavior on color {
        ColorAnimation {
            duration: Kirigami.Units.shortDuration
        }
    }

    HoverHandler {
        id: survol
    }

    MouseArea {
        anchors.fill: parent
        enabled: carte.cliquable
        cursorShape: Qt.PointingHandCursor
        onClicked: carte.basculee(!carte.coche)
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
            source: carte.icone
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                Label {
                    text: carte.titre
                    font.weight: Font.DemiBold
                }
                Label {
                    visible: carte.mention.length > 0
                    text: carte.mention
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                }
            }
            Label {
                Layout.fillWidth: true
                text: carte.detail
                wrapMode: Text.Wrap
                opacity: 0.8
            }
        }

        CheckBox {
            id: caseOption
            Layout.alignment: Qt.AlignVCenter
            checked: carte.coche
            enabled: carte.modifiable
            Accessible.name: carte.titre
            onToggled: {
                carte.basculee(checked);
                checked = Qt.binding(() => carte.coche);
            }
        }
    }
}
