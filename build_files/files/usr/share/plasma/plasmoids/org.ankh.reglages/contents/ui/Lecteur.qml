/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Lecteur multimédia des paramètres rapides (D-052, lot 6a ; mon choix du
// 2026-10-22) : comme la carte que Windows 11 montre au-dessus de ses
// paramètres rapides, seulement quand quelque chose joue ou est en pause.
// Application, titre et artiste à gauche, pochette de 64 à droite, et les
// boutons précédent, lecture ou pause, suivant. Les données viennent du
// lecteur MPRIS en cours (org.kde.plasma.private.mpris, le module du lecteur
// de Plasma). Carte aux couleurs CardBackgroundFillColorDefault et
// CardStrokeColorDefault de WinUI, coins de 8.

import QtQuick

import org.kde.kirigami as Kirigami
import org.ankh.commun

Rectangle {
    id: carte

    required property var etat
    readonly property var lecteur: etat.lecteur

    implicitHeight: 124
    radius: 8
    color: couleurs.carte
    border.width: 1
    border.color: couleurs.bordCarte

    Couleurs {
        id: couleurs
    }

    // Application
    Row {
        id: application
        x: 16
        y: 14
        spacing: 8
        Kirigami.Icon {
            width: 16
            height: 16
            source: carte.lecteur ? carte.lecteur.iconName : ""
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: carte.lecteur ? carte.lecteur.identity : ""
            font: Kirigami.Theme.smallFont
            color: couleurs.texteSecondaire
        }
    }

    // Titre et artiste
    Column {
        x: 16
        anchors.top: application.bottom
        anchors.topMargin: 8
        width: pochette.x - x - 12
        spacing: 2
        Text {
            width: parent.width
            text: carte.lecteur ? carte.lecteur.track : ""
            elide: Text.ElideRight
            font.family: Kirigami.Theme.defaultFont.family
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: Kirigami.Theme.textColor
        }
        Text {
            width: parent.width
            text: carte.lecteur ? carte.lecteur.artist : ""
            elide: Text.ElideRight
            font: Kirigami.Theme.smallFont
            color: couleurs.texteSecondaire
        }
    }

    // Pochette
    Rectangle {
        id: pochette
        width: 64
        height: 64
        x: carte.width - width - 16
        y: 14
        radius: 4
        color: couleurs.controle
        clip: true
        Image {
            id: image
            anchors.fill: parent
            source: carte.lecteur ? carte.lecteur.artUrl : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(128, 128)
            asynchronous: true
        }
        // Sans pochette, l'icône de l'application, comme Windows 11
        Kirigami.Icon {
            visible: image.status !== Image.Ready
            anchors.centerIn: parent
            width: 32
            height: 32
            source: carte.lecteur ? carte.lecteur.iconName : ""
        }
    }

    // Commandes
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        spacing: 8
        BoutonDiscret {
            icone: "media-skip-backward"
            infobulle: "Précédent"
            opacity: carte.lecteur && carte.lecteur.canGoPrevious ? 1 : 0.4
            onClique: if (carte.lecteur && carte.lecteur.canGoPrevious) carte.lecteur.Previous()
        }
        BoutonDiscret {
            icone: carte.etat.lecture ? "media-playback-pause" : "media-playback-start"
            infobulle: carte.etat.lecture ? "Pause" : "Lecture"
            onClique: if (carte.lecteur) carte.lecteur.PlayPause()
        }
        BoutonDiscret {
            icone: "media-skip-forward"
            infobulle: "Suivant"
            opacity: carte.lecteur && carte.lecteur.canGoNext ? 1 : 0.4
            onClique: if (carte.lecteur && carte.lecteur.canGoNext) carte.lecteur.Next()
        }
    }
}
