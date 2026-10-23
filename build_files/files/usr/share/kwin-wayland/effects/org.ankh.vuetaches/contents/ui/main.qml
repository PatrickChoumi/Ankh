/*
    SPDX-FileCopyrightText: 2026 Ankh
    SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Vue des tâches d'Ankh (D-052, lot 7b) : le lien avec KWin. KWin charge ce
// paquet comme un effet écrit en QML (KWin/Effect, « declarativescript »,
// src/effect/effectloader.cpp de KWin 6.7) ; le bouton « Vue des tâches »
// de la barre l'ouvre et le ferme. Sur chaque écran, il pose le fond d'écran flou du bureau en cours,
// la vue des tâches (VueTaches.qml) et, par-dessus, la barre des tâches, qui
// reste visible comme dans Windows 11. Le fond flou, les vignettes et la
// barre sont faits comme dans la vue des fenêtres et la vue d'ensemble de
// KWin 6.7 (src/plugins/windowview/qml/Main.qml,
// src/plugins/overview/qml/DesktopView.qml).

import QtQuick
import Qt5Compat.GraphicalEffects

import org.kde.kwin as KWin

KWin.SceneEffect {
    id: effet

    delegate: FocusScope {
        id: ecran

        readonly property var cible: KWin.SceneView.screen
        // Place libre de l'écran, sans la barre des tâches, dans l'écran
        readonly property rect zoneLibre: {
            const z = KWin.Workspace.clientArea(KWin.Workspace.MaximizeArea, cible, KWin.Workspace.currentDesktop);
            return Qt.rect(z.x - cible.geometry.x, z.y - cible.geometry.y, z.width, z.height);
        }
        // Fenêtres du bureau montré, la plus récente (la plus haute) d'abord,
        // sans celles qu'Alt+Tab ne montre pas non plus (skipSwitcher)
        property int revision: 0
        readonly property var fenetres: {
            ecran.revision;
            const liste = [];
            for (let i = 0; i < suivi.count; i++) {
                const objet = suivi.objectAt(i);
                if (objet && objet.window && !objet.window.skipSwitcher) {
                    liste.push(objet.window);
                }
            }
            liste.sort((a, b) => b.stackingOrder - a.stackingOrder);
            return liste;
        }

        focus: true

        KWin.WindowModel {
            id: pile
        }

        KWin.VirtualDesktopModel {
            id: modeleBureaux
        }

        Instantiator {
            id: suivi
            model: KWin.WindowFilterModel {
                activity: KWin.Workspace.currentActivity
                desktop: vueTaches.bureauMontre
                screenName: ecran.cible.name
                windowModel: pile
                minimizedWindows: true
                windowType: KWin.WindowFilterModel.Normal | KWin.WindowFilterModel.Dialog
            }
            delegate: QtObject {
                required property var window
            }
            onObjectAdded: ecran.revision++
            onObjectRemoved: ecran.revision++
        }

        // Fond d'écran du bureau en cours, flou
        KWin.DesktopBackground {
            activity: KWin.Workspace.currentActivity
            desktop: KWin.Workspace.currentDesktop
            outputName: ecran.cible.name
            layer.enabled: true
            layer.effect: FastBlur {
                radius: 64
            }
        }

        VueTaches {
            id: vueTaches
            anchors.fill: parent
            focus: true
            fenetres: ecran.fenetres
            bureaux: KWin.Workspace.desktops
            bureauCourant: KWin.Workspace.currentDesktop
            bureauxMax: modeleBureaux.maximum
            zone: ecran.zoneLibre
            rapportEcran: ecran.cible.geometry.width / Math.max(1, ecran.cible.geometry.height)

            vignette: Component {
                KWin.WindowThumbnail {
                    property var fenetre
                    anchors.fill: parent
                    wId: fenetre.internalId
                }
            }

            // Aperçu d'un bureau : son fond d'écran et ses fenêtres à leur
            // place, réduits à la taille de l'aperçu
            apercuBureau: Component {
                Item {
                    id: apercu
                    property var bureau
                    anchors.fill: parent

                    Item {
                        width: ecran.cible.geometry.width
                        height: ecran.cible.geometry.height
                        scale: apercu.height / Math.max(1, height)
                        transformOrigin: Item.TopLeft

                        KWin.DesktopBackground {
                            activity: KWin.Workspace.currentActivity
                            desktop: apercu.bureau
                            outputName: ecran.cible.name
                        }

                        Repeater {
                            model: KWin.WindowFilterModel {
                                activity: KWin.Workspace.currentActivity
                                desktop: apercu.bureau
                                screenName: ecran.cible.name
                                windowModel: pile
                                windowType: KWin.WindowFilterModel.Normal | KWin.WindowFilterModel.Dialog
                            }
                            delegate: KWin.WindowThumbnail {
                                required property var window
                                wId: window.internalId
                                x: window.x - ecran.cible.geometry.x
                                y: window.y - ecran.cible.geometry.y
                                width: window.width
                                height: window.height
                                z: window.stackingOrder
                            }
                        }
                    }
                }
            }

            onFenetreActivee: fenetre => {
                KWin.Workspace.activeWindow = fenetre;
                effet.visible = false;
            }
            onFenetreFermee: fenetre => fenetre.closeWindow()
            onBureauActive: bureau => {
                KWin.Workspace.currentDesktop = bureau;
                effet.visible = false;
            }
            onBureauSurvole: bureau => vueTaches.bureauMontre = bureau
            onBureauAjoute: modeleBureaux.create(KWin.Workspace.desktops.length)
            onBureauRetire: bureau => {
                const index = KWin.Workspace.desktops.indexOf(bureau);
                if (index >= 0 && KWin.Workspace.desktops.length > 1) {
                    modeleBureaux.remove(index);
                    vueTaches.bureauMontre = Qt.binding(() => KWin.Workspace.currentDesktop);
                }
            }
            onFermer: effet.visible = false
        }

        // La barre des tâches, par-dessus le voile, à sa place
        Instantiator {
            model: KWin.WindowFilterModel {
                desktop: KWin.Workspace.currentDesktop
                screenName: ecran.cible.name
                windowModel: pile
                windowType: KWin.WindowFilterModel.Dock
            }
            delegate: KWin.WindowThumbnail {
                required property var window
                wId: window.internalId
                x: window.x - ecran.cible.geometry.x
                y: window.y - ecran.cible.geometry.y
                z: 2
                visible: !window.hidden
            }
            onObjectAdded: (index, objet) => objet.parent = ecran
        }
    }

    // Sans touche : Ankh garde les raccourcis de KDE (mon choix du
    // 2026-10-23). Le bouton « Vue des tâches » de la barre
    // (plasmoids/org.ankh.vuetaches) appelle cette action par son nom ; une
    // touche peut lui être donnée dans les réglages des raccourcis.
    KWin.ShortcutHandler {
        name: "AnkhVueTaches"
        text: "Vue des tâches"
        onActivated: effet.visible = !effet.visible
    }
}
