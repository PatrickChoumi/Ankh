/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2015 David Rosca <nowrep@gmail.com>
    SPDX-FileCopyrightText: 2023 Natalie Clarius <natalie.clarius@kde.org>
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

// État du système pour les paramètres rapides d'Ankh (D-052, lot 6a) : ce
// que montrent les tuiles, les curseurs, le lecteur et le bouton de la
// barre, et ce qu'ils font. Tout passe par les modules QML de Plasma 6.7.5,
// comme dans leurs applets (compilées, donc non modifiables) :
// - réseau : org.kde.plasma.networkmanagement (plasma-nm, applet/main.qml) ;
// - Bluetooth : org.kde.bluezqt (bluedevil, src/applet/qml/main.qml) ;
// - son : org.kde.plasma.private.volume (plasma-pa, applet/main.qml) ;
// - luminosité, éclairage nocturne, mode sombre :
//   org.kde.plasma.private.brightnesscontrolplugin (powerdevil,
//   applets/brightness) ;
// - économie d'énergie : org.kde.plasma.private.batterymonitor (powerdevil) ;
// - batterie : org.kde.plasma.private.battery (plasma-workspace) ;
// - Ne pas déranger : org.kde.notificationmanager (plasma-workspace,
//   applets/notifications/global/Globals.qml) ;
// - lecteur multimédia : org.kde.plasma.private.mpris (plasma-workspace).
// L'aperçu hors écran remplace cet objet par un faux, de même interface.

import QtQuick

import org.kde.bluezqt as BluezQt
import org.kde.kcmutils as KCMUtils
import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.private.battery as Batterie
import org.kde.plasma.private.batterymonitor as Energie
import org.kde.plasma.private.brightnesscontrolplugin as Luminosite
import org.kde.plasma.private.mpris as Mpris
import org.kde.plasma.private.volume as Volume
import org.kde.plasma.workspace.dbus as DBus

Item {
    id: etat

    visible: false

    // --- Réseau ---------------------------------------------------------

    readonly property bool wifiDisponible: appareils.wirelessDeviceAvailable
    readonly property bool wifiActif: connexions.wirelessEnabled && !avionActif
    readonly property bool wifiMateriel: connexions.wirelessHwEnabled
    readonly property string iconeReseau: icone.connectionIcon || "network-disconnect"
    readonly property bool avionDisponible: appareils.wirelessDeviceAvailable || appareils.modemDeviceAvailable
        || btDisponible
    readonly property bool avionActif: PlasmaNM.Configuration.airplaneModeEnabled
    // Réseaux Wi-Fi, pour la page Wi-Fi (le même modèle que l'applet de Plasma)
    readonly property var reseaux: modeleReseaux

    function basculerWifi(): void {
        gestion.enableWireless(!connexions.wirelessEnabled);
    }

    function basculerAvion(): void {
        const actif = !PlasmaNM.Configuration.airplaneModeEnabled;
        gestion.enableAirplaneMode(actif);
        PlasmaNM.Configuration.airplaneModeEnabled = actif;
    }

    function chercherReseaux(): void {
        gestion.requestScan();
    }

    function connecter(connexion: string, appareil: string, specifique: string): void {
        gestion.activateConnection(connexion, appareil, specifique);
    }

    function connecterNouveau(appareil: string, specifique: string, motDePasse: string): void {
        gestion.addAndActivateConnection(appareil, specifique, motDePasse);
    }

    function deconnecter(connexion: string, appareil: string): void {
        gestion.deactivateConnection(connexion, appareil);
    }

    PlasmaNM.AvailableDevices {
        id: appareils
    }

    PlasmaNM.EnabledConnections {
        id: connexions
    }

    PlasmaNM.ConnectionIcon {
        id: icone
    }

    PlasmaNM.Handler {
        id: gestion
    }

    PlasmaNM.NetworkModel {
        id: modeleBrut
    }

    PlasmaNM.AppletProxyModel {
        id: modeleReseaux
        sourceModel: modeleBrut
    }

    // --- Bluetooth ------------------------------------------------------

    readonly property bool btDisponible: BluezQt.Manager.bluetoothBlocked || BluezQt.Manager.adapters.length > 0
    readonly property bool btActif: !BluezQt.Manager.bluetoothBlocked && BluezQt.Manager.bluetoothOperational
    readonly property var appareilsBt: BluezQt.Manager.devices

    function basculerBt(): void {
        const actif = !btActif;
        BluezQt.Manager.bluetoothBlocked = !actif;
        BluezQt.Manager.adapters.forEach(adaptateur => {
            adaptateur.powered = actif;
        });
    }

    // --- Son ------------------------------------------------------------

    readonly property var sortie: Volume.PreferredDevice.sink
    readonly property bool sonDisponible: sortie !== null && sortie.name !== "auto_null"
    readonly property int volume: sortie ? Math.round(sortie.volume / Volume.PulseAudio.NormalVolume * 100) : 0
    readonly property bool muet: sortie ? sortie.muted : true
    readonly property string iconeSon: Volume.AudioIcon.forVolume(volume, muet, "")
    readonly property var sorties: modeleSorties

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

    Volume.SinkModel {
        id: modeleSorties
    }

    // --- Luminosité, éclairage nocturne, mode sombre ----------------------

    // Écran intégré seulement, comme Windows 11 : un écran externe se règle
    // par ses propres boutons
    property string ecranInterne: ""
    property int luminosite: 0
    property int luminositeMax: 0
    readonly property bool luminositeDisponible: ecranInterne !== "" && luminositeMax > 0
    readonly property int luminositePourcent: luminositeDisponible ? Math.round(luminosite * 100 / luminositeMax) : 0

    function reglerLuminosite(pourcent: int): void {
        if (luminositeDisponible) {
            controleLuminosite.setBrightness(ecranInterne, Math.round(Math.max(1, Math.min(100, pourcent)) * luminositeMax / 100));
        }
    }

    Luminosite.ScreenBrightnessControl {
        id: controleLuminosite
        isSilent: true
    }

    Instantiator {
        model: controleLuminosite.displays
        delegate: QtObject {
            required property string displayName
            required property bool isInternal
            required property int brightness
            required property int maxBrightness

            function noter(): void {
                if (isInternal) {
                    etat.ecranInterne = displayName;
                    etat.luminosite = brightness;
                    etat.luminositeMax = maxBrightness;
                }
            }
            onBrightnessChanged: noter()
            onMaxBrightnessChanged: noter()
            Component.onCompleted: noter()
        }
    }

    // Éclairage nocturne de KWin (org.kde.KWin.NightLight). S'il n'est pas
    // activé dans les réglages, la tuile ouvre sa page ; sinon, elle le
    // suspend ou le reprend, comme l'applet de Plasma (NightLightItem.qml).
    readonly property bool nuitDisponible: Boolean(nuit.properties.available)
    readonly property bool nuitActivee: Boolean(nuit.properties.enabled)
    readonly property bool nuitActive: nuitActivee && Boolean(nuit.properties.running) && !Boolean(nuit.properties.inhibited)

    function basculerNuit(): void {
        if (nuitActivee) {
            Luminosite.NightLightInhibitor.toggleInhibition();
        } else {
            KCMUtils.KCMLauncher.openSystemSettings("kcm_nightlight");
        }
    }

    DBus.Properties {
        id: nuit
        busType: DBus.BusType.Session
        service: "org.kde.KWin.NightLight"
        path: "/org/kde/KWin/NightLight"
        iface: "org.kde.KWin.NightLight"
    }

    // Mode sombre : bascule entre les thèmes globaux clair et sombre d'Ankh
    // (DefaultLightLookAndFeel et DefaultDarkLookAndFeel de kdeglobals)
    readonly property bool sombre: Luminosite.DarkModeControl.darkMode

    function basculerSombre(): void {
        Luminosite.DarkModeControl.darkMode = !Luminosite.DarkModeControl.darkMode;
    }

    // --- Économie d'énergie et batterie -----------------------------------

    readonly property bool economieDisponible: profils.isPowerProfileDaemonInstalled && profils.profiles.includes("power-saver")
    readonly property bool economieActive: profils.activeProfile === "power-saver"

    function basculerEconomie(): void {
        profils.setProfile(economieActive ? "balanced" : "power-saver");
    }

    Energie.PowerProfilesControl {
        id: profils
        isSilent: true
    }

    readonly property bool batterieDisponible: batterie.hasInternalBatteries
    readonly property int batteriePourcent: batterie.percent
    readonly property bool batterieBranchee: batterie.pluggedIn
    readonly property string iconeBatterie: {
        const niveau = Math.min(100, Math.round(batterie.percent / 10) * 10);
        return "battery-" + String(niveau).padStart(3, "0") + (batterie.pluggedIn ? "-charging" : "");
    }

    Batterie.BatteryControlModel {
        id: batterie
    }

    // --- Ne pas déranger ------------------------------------------------

    readonly property bool nePasDeranger: {
        const jusqua = reglagesNotifications.notificationsInhibitedUntil;
        return (jusqua && !isNaN(jusqua.getTime()) && Date.now() < jusqua.getTime())
            || reglagesNotifications.notificationsInhibitedByApplication;
    }

    // Comme Globals.qml de Plasma : jusqu'à nouvel ordre (date lointaine), ou
    // fin de toutes les suspensions
    function basculerNePasDeranger(): void {
        if (nePasDeranger) {
            reglagesNotifications.notificationsInhibitedUntil = undefined;
            reglagesNotifications.revokeApplicationInhibitions();
        } else {
            const loin = new Date();
            loin.setFullYear(loin.getFullYear() + 1);
            reglagesNotifications.notificationsInhibitedUntil = loin;
        }
        reglagesNotifications.save();
    }

    NotificationManager.Settings {
        id: reglagesNotifications
        live: true
    }

    // --- Lecteur multimédia -----------------------------------------------

    readonly property var lecteur: mpris.currentPlayer
    readonly property bool lecteurPresent: lecteur !== null && lecteur.canControl
        && (lecteur.track !== "" || lecteur.identity !== "")
    readonly property bool lecture: lecteurPresent && lecteur.playbackStatus === Mpris.PlaybackStatus.Playing

    Mpris.Mpris2Model {
        id: mpris
    }

    // --- Réglages ---------------------------------------------------------

    function ouvrir(module: string): void {
        KCMUtils.KCMLauncher.openSystemSettings(module);
    }
}
