/*
    SPDX-FileCopyrightText: 2026 Ankh
    SPDX-FileCopyrightText: 2020 Chris Holland <zrenfire@gmail.com>
    SPDX-FileCopyrightText: 2023 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// Alt+Tab d'Ankh (D-052, lot 7a) : le lien avec KWin. KWin charge ce
// fichier quand Alt+Tab est pressé (paquet KWin/WindowSwitcher, choisi par
// [TabBox] LayoutName dans kwinrc) ; il ouvre au centre de l'écran un volet
// du style Plasma d'Ankh (coins de 8, verre) avec le sélecteur
// (Selecteur.qml). Construit comme la grille de vignettes de KWin 6.7
// (src/tabbox/switchers/thumbnail_grid/contents/ui/main.qml), dont viennent
// le volet et ses réglages.

import QtQuick

import org.kde.kwin as KWin
import org.kde.plasma.core as PlasmaCore

KWin.TabBoxSwitcher {
    id: tabBox

    Instantiator {
        active: tabBox.visible
        delegate: PlasmaCore.Dialog {
            location: PlasmaCore.Types.Floating
            visible: true
            flags: Qt.Popup | Qt.X11BypassWindowManagerHint
            x: tabBox.screenGeometry.x + Math.round((tabBox.screenGeometry.width - width) / 2)
            y: tabBox.screenGeometry.y + Math.round((tabBox.screenGeometry.height - height) / 2)

            mainItem: Selecteur {
                modele: tabBox.model
                courant: tabBox.currentIndex
                largeurMax: Math.round(tabBox.screenGeometry.width * 0.9)
                hauteurMax: Math.round(tabBox.screenGeometry.height * 0.8)
                rapportEcran: tabBox.screenGeometry.width / Math.max(1, tabBox.screenGeometry.height)
                peutFermer: typeof tabBox.model.close !== "undefined"
                vignette: Component {
                    KWin.WindowThumbnail {
                        property var fenetre
                        wId: fenetre
                    }
                }
                onChoisi: index => tabBox.currentIndex = index
                onActive: index => tabBox.model.activate(index)
                onFerme: index => tabBox.model.close(index)
            }

            onSceneGraphError: () => {
                // Laissé vide, comme dans KWin : sinon QtQuick peut arrêter
                // KWin (qFatal) après une réinitialisation de la carte graphique
            }
        }
    }
}
