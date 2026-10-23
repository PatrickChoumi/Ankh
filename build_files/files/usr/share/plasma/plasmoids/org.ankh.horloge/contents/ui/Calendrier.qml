/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Calendrier de l'horloge d'Ankh (D-052, lot 6b), comme celui de Windows 11
// (CalendarView de WinUI, CommonStyles/CalendarView_themeresources.xaml) :
// en haut, la date du jour en toutes lettres ; puis le mois affiché et ses
// flèches ; les initiales des jours ; six semaines de cases de 40×40.
// Aujourd'hui est un rond rempli de l'accent exact, son chiffre blanc ou
// noir (comme le style d'Ankh, lot 3) ; les jours des autres mois sont en
// texte secondaire. Les jours viennent du modèle de calendrier de Plasma
// (org.kde.plasma.workspace.calendar, plasma-workspace 6.7.5), qui suit le
// premier jour de la semaine de la langue.

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.calendar as PlasmaCalendar

import org.ankh.commun

Item {
    id: calendrier

    property date aujourdhui: new Date()

    // Marges des côtés : sept cases de 40, espacées de 4, au centre
    readonly property int largeurGrille: 7 * 40 + 6 * 4
    readonly property int marge: Math.round((width - largeurGrille) / 2)

    implicitHeight: 48 + 40 + 24 + 6 * 44 + 12

    Couleurs {
        id: couleurs
    }

    PlasmaCalendar.Calendar {
        id: modele
        days: 7
        weeks: 6
        firstDayOfWeek: Qt.locale().firstDayOfWeek
        today: calendrier.aujourdhui
    }

    function revenirAujourdhui(): void {
        modele.resetToToday();
    }

    // Date du jour, en toutes lettres
    Text {
        x: 16
        height: 48
        verticalAlignment: Text.AlignVCenter
        text: {
            const texte = calendrier.aujourdhui.toLocaleDateString(Qt.locale(), "dddd d MMMM");
            return texte.charAt(0).toUpperCase() + texte.slice(1);
        }
        font.family: Kirigami.Theme.defaultFont.family
        font.pixelSize: 14
        font.weight: Font.DemiBold
        color: Kirigami.Theme.textColor
    }
    Rectangle {
        y: 48
        width: parent.width
        height: 1
        color: couleurs.separateur
    }

    // Mois affiché et ses flèches
    Item {
        y: 49
        width: parent.width
        height: 40
        Text {
            x: calendrier.marge
            anchors.verticalCenter: parent.verticalCenter
            text: {
                const texte = modele.displayedDate.toLocaleDateString(Qt.locale(), "MMMM yyyy");
                return texte.charAt(0).toUpperCase() + texte.slice(1);
            }
            font.family: Kirigami.Theme.defaultFont.family
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: Kirigami.Theme.textColor
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: calendrier.marge - 8
            anchors.verticalCenter: parent.verticalCenter
            BoutonDiscret {
                icone: "go-up"
                infobulle: "Mois précédent"
                onClique: modele.previousMonth()
            }
            BoutonDiscret {
                icone: "go-down"
                infobulle: "Mois suivant"
                onClique: modele.nextMonth()
            }
        }
    }

    // Initiales des jours (« lu », « ma »… en français)
    Row {
        x: calendrier.marge
        y: 49 + 40
        spacing: 4
        Repeater {
            model: 7
            Text {
                required property int index
                width: 40
                height: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: {
                    const jour = (modele.firstDayOfWeek + index) % 7;
                    return Qt.locale().standaloneDayName(jour, Locale.ShortFormat).replace(".", "").slice(0, 2);
                }
                font: Kirigami.Theme.smallFont
                color: Kirigami.Theme.textColor
            }
        }
    }

    // Jours
    Grid {
        x: calendrier.marge
        y: 49 + 40 + 24
        columns: 7
        columnSpacing: 4
        rowSpacing: 4
        Repeater {
            model: modele.daysModel
            delegate: Item {
                id: jour

                required property int dayNumber
                required property int monthNumber
                required property int yearNumber

                readonly property bool ceMois: monthNumber === modele.displayedDate.getMonth() + 1
                readonly property bool estAujourdhui: dayNumber === calendrier.aujourdhui.getDate()
                    && monthNumber === calendrier.aujourdhui.getMonth() + 1
                    && yearNumber === calendrier.aujourdhui.getFullYear()

                width: 40
                height: 40

                Rectangle {
                    anchors.centerIn: parent
                    width: 36
                    height: 36
                    radius: 18
                    color: jour.estAujourdhui ? couleurs.accent
                        : (zone.containsMouse ? couleurs.discretSurvol : "transparent")
                }
                Text {
                    anchors.centerIn: parent
                    text: jour.dayNumber
                    color: jour.estAujourdhui ? couleurs.surAccent
                        : (jour.ceMois ? Kirigami.Theme.textColor : couleurs.texteInactif)
                }
                MouseArea {
                    id: zone
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}
