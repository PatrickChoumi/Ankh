/*
    SPDX-FileCopyrightText: 2026 Ankh

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma Singleton

// Mesures du Démarrer d'Ankh (D-052, lot 5) : celles du Démarrer « classique »
// de Windows 11 (21H2 à 24H2, mon choix du 2026-10-22), en pixels à l'échelle
// 100 %. Elles remplacent les mesures que Kickoff tire du thème
// (KickoffSingleton.qml de plasma-desktop 6.7.5).
//
// Microsoft ne publie aucune mesure de Démarrer : sauf mention contraire,
// elles sont relevées au pixel sur des images officielles de Microsoft
// (recherche du lot 5, 2026-10-22, § 3) :
// - A : Start.png du blog Windows Insider (2021-06, build 22000.51, 200 %,
//   sans champ de recherche) ;
// - B : Start-Resize.png (2021-12, build 22509, réduite à 0,656).
// Les positions verticales sont prises depuis le haut du volet visible, donc
// avec le champ de recherche (A + 64 px). Précision : ±1 px sur A, ±2 px
// sur B. Les valeurs suivies de « À VALIDER » ne sont qu'estimées.
// Le banc compare la taille du volet à build_files/interface/jetons.toml.

import QtQuick

QtObject {
    // --- Volet (A : 1280×1324 à 200 %, + 64 de recherche ; B : 638×725)
    readonly property int largeurVolet: 640
    readonly property int hauteurVolet: 726

    // --- Bords : la grille à 32, les titres, icônes et textes à 64 (A)
    readonly property int bordGrille: 32
    readonly property int bordTexte: 64

    // --- Champ de recherche (B) : à 32 du haut et des côtés, 576 de large,
    // environ 40 de haut avec son trait d'accent de 2 px en bas (À VALIDER)
    readonly property int rechercheHaut: 32
    readonly property int rechercheLargeur: 576
    readonly property int rechercheHauteur: 40
    readonly property int rechercheTrait: 2
    readonly property int rechercheIcone: 16
    readonly property int rechercheRetrait: 12

    // --- Titres « Épinglé », « Recommandé » et « Toutes les applications » :
    // 14 px, semi-gras (A : hauteur des majuscules de 10 px, ±1, À VALIDER).
    // Haut des majuscules à 110 du haut du volet, donc ligne de base à 120.
    readonly property int titreTaille: 14
    readonly property int titreLigneDeBase: 120
    // Bouton « Toutes les applications › » : 24 de haut, bord droit à 64
    // du bord (A : 156×48 à 200 % ; B : 79×23), centré sur le titre
    readonly property int boutonHauteur: 24
    readonly property int boutonRetrait: 8
    readonly property int boutonHaut: 103

    // --- Grille des épingles (A) : 6 colonnes × 3 rangées, cellules de
    // 96 × 84, icônes de 32 (D-052 : 32 pour les épingles de Démarrer),
    // libellé de 12 px sur une ligne, 8 px sous l'icône. Première rangée
    // d'icônes à 152 du haut ; la cellule commence 14 px au-dessus
    // (84 = 14 + 32 + 8 + 16 + 14, marges égales : À VALIDER).
    readonly property int colonnes: 6
    readonly property int rangees: 3
    readonly property int celluleLargeur: 96
    readonly property int celluleHauteur: 84
    readonly property int icone: 32
    readonly property int ecartIconeLibelle: 8
    readonly property int celluleRetrait: 14
    readonly property int grilleHaut: 138
    // Points des pages, à droite, à environ 15 px du bord (B, À VALIDER)
    readonly property int pointsBord: 15
    readonly property int pointTaille: 4
    readonly property int pointEcart: 8

    // --- Recommandé (A) : titre à 432 du haut (ligne de base à 442) ;
    // 2 colonnes de 288 × 3 rangées de 56 ; icônes de 32 à 64 et 352 du
    // bord, nom et détail sur deux lignes, 12 px après l'icône
    readonly property int recommandeLigneDeBase: 442
    readonly property int recommandeHaut: 462
    readonly property int recommandeColonnes: 2
    readonly property int recommandeRangees: 3
    readonly property int recommandeLargeur: 288
    readonly property int recommandeHauteur: 56
    readonly property int recommandeRetrait: 16

    // --- Pied (A) : 64 de haut, trait en haut ; avatar de 32 à 64 du bord
    // gauche, nom 12 px plus loin ; bouton d'alimentation (glyphe de 16),
    // bord droit à 64
    readonly property int piedHauteur: 64
    readonly property int avatar: 32
    readonly property int ecartAvatarNom: 12
    readonly property int glyphe: 16
    readonly property int boutonPied: 40

    // --- Page « Toutes les applications » : aucune mesure de Microsoft.
    // Élément de liste de 40 (WinUI ListViewItemMinHeight), icône de 24
    // (À VALIDER sur une capture). Grille des lettres : 8 colonnes de 72 × 56
    // (À VALIDER).
    readonly property int ligneListe: 40
    readonly property int ligneListeDouble: 52
    readonly property int iconeListe: 24
    readonly property int lettreLargeur: 72
    readonly property int lettreHauteur: 56
    readonly property int lettreTaille: 20

    // --- Commun : textes de 14 (corps) et 12 (légende), coins de 4 des
    // contrôles (WinUI ControlCornerRadius), trait de focus de 2 et trait
    // intérieur de 1 (D-052)
    readonly property int texteCorps: 14
    readonly property int texteLegende: 12
    readonly property int rayon: 4
    readonly property int focusExterieur: 2
    readonly property int focusInterieur: 1
    // Fonds au survol et à l'appui : la couleur du texte, très atténuée,
    // comme les boutons de la barre (style Plasma d'Ankh, lot 4)
    readonly property real opaciteSurvol: 0.06
    readonly property real opaciteAppui: 0.04
    readonly property real opaciteTrait: 0.12
    readonly property real opacitePied: 0.035
    readonly property real opaciteSecondaire: 0.72
    // Les durées des animations sont celles de Kirigami, déjà ramenées à
    // celles de Windows 11 par AnimationDurationFactor (D-052, lot 1)
}
