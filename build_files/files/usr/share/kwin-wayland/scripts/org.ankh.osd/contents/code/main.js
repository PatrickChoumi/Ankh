// SPDX-FileCopyrightText: 2026 Ankh
// SPDX-License-Identifier: GPL-2.0-or-later
//
// D-052, lot 10p : l'affichage du volume, de la luminosité ou de la
// disposition du clavier (fenêtres « onScreenDisplay » de Plasma) se pose en
// bas de l'écran, centré, à 12 px au-dessus de la barre, comme celui de
// Windows 11, au lieu des deux tiers de la hauteur de l'écran où KWin le
// place (Placement::placeOnScreenDisplay, src/placement.cpp de KWin 6.7).
// 12 px : l'écart des volets d'Ankh à la barre (lot 4, mon choix du
// 2026-10-22). La zone de placement de KWin exclut déjà la barre.

const ECART = 12;

function placer(fenetre) {
    const zone = workspace.clientArea(KWin.PlacementArea, fenetre);
    const g = fenetre.frameGeometry;
    if (g.width <= 0 || g.height <= 0) {
        return;
    }
    const x = Math.round(zone.x + (zone.width - g.width) / 2);
    const y = Math.round(zone.y + zone.height - ECART - g.height);
    if (Math.round(g.x) !== x || Math.round(g.y) !== y) {
        fenetre.frameGeometry = { x: x, y: y, width: g.width, height: g.height };
    }
}

function suivre(fenetre) {
    if (!fenetre.onScreenDisplay) {
        return;
    }
    placer(fenetre);
    // La taille change avec le texte affiché : la place suit
    fenetre.frameGeometryChanged.connect(() => placer(fenetre));
}

workspace.windowList().forEach(suivre);
workspace.windowAdded.connect(suivre);
