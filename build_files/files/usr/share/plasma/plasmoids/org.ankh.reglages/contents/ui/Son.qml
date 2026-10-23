/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

// Son des paramètres rapides d'Ankh (D-052, lot 6a) : la sortie par défaut,
// son volume et son silence, et la liste des sorties, comme l'applet du son
// de Plasma (applet/main.qml et ListItemBase.qml de plasma-pa 6.7.5, même
// licence). Ce fichier est à part : plasma-pa enregistre ses types dans son
// code (qmlRegisterType, src/qml/plugin.cpp), sans fichier de description,
// et qmllint ne peut pas les lire. verifier-reglages.sh le laisse donc de
// côté ; la sonde de la construction le crée avec les vrais types.

import QtQuick

import org.kde.plasma.private.volume as Volume

QtObject {
    readonly property var sortie: Volume.PreferredDevice.sink
    readonly property bool disponible: sortie !== null && sortie.name !== "auto_null"
    readonly property int volume: sortie ? Math.round(sortie.volume / Volume.PulseAudio.NormalVolume * 100) : 0
    readonly property bool muet: sortie ? sortie.muted : true
    readonly property string icone: Volume.AudioIcon.forVolume(volume, muet, "")
    readonly property var sorties: Volume.SinkModel {}

    function regler(pourcent: int): void {
        if (sortie) {
            sortie.volume = Math.round(Volume.PulseAudio.NormalVolume * Math.max(0, Math.min(100, pourcent)) / 100);
            sortie.muted = pourcent === 0;
        }
    }

    function basculerMuet(): void {
        if (sortie) {
            sortie.muted = !sortie.muted;
        }
    }
}
