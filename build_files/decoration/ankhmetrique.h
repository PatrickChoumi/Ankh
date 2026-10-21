/*
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2026 Ankh
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 *
 * Décoration des fenêtres d'Ankh (D-052, lot 2), dérivée de celle de Breeze
 * 6.7.5 (kdecoration/ de https://invent.kde.org/plasma/breeze, commit
 * ca217f1). Mesures de Windows 11, en pixels à l'échelle 100 % :
 * - WinUI (https://github.com/microsoft/microsoft-ui-xaml, commit 866ba81) :
 *   controls/dev/TitleBar/TitleBar_themeresources.xaml,
 *   controls/dev/CommonStyles/Common_themeresources_any.xaml,
 *   controls/dev/CommonStyles/CornerRadius_themeresources.xaml,
 *   dxaml/xcp/components/graphics/inc/DropShadowRecipe.h ;
 * - boutons de la barre de titre de Windows, copiés par Windows Terminal
 *   (https://github.com/microsoft/terminal, commit 44b440b) :
 *   src/cascadia/TerminalApp/MinMaxCloseControl.xaml.
 */

#pragma once

#include <QColor>

namespace Ankh::Metrique
{
// Barre de titre : TitleBarCompactHeight
static constexpr qreal BarreDeTitre = 32;

// Icône de l'application : 16×16 (TitleBarIconMaxWidth), à 16 px du bord
// (TitleBarLeftPaddingWidth 2 + TitleBarLeftHeaderPaddingWidth 14), puis
// 16 px avant le titre (TitleBarIconMargin) et 8 px après lui
// (TitleBarTitleMargin)
static constexpr qreal Icone = 16;
static constexpr qreal IconeBord = 16;
static constexpr qreal IconeTitre = 16;
static constexpr qreal TitreFin = 8;

// Icône et titre d'une fenêtre inactive : TitleBarDeactivatedOpacity
static constexpr qreal OpaciteInactive = 0.5;

// Boutons réduire, agrandir et fermer : 46 de large, toute la hauteur de la
// barre, symbole de 10×10 (Viewbox du modèle)
static constexpr qreal BoutonLargeur = 46;
static constexpr qreal Symbole = 10;

// Coins des fenêtres : OverlayCornerRadius ; contour de 1 px
static constexpr qreal Rayon = 8;

// Marge invisible pour redimensionner, autour d'une fenêtre sans bord
static constexpr qreal BordInvisible = 8;
// En haut, les 4 premiers px de la barre de titre servent à redimensionner,
// boutons compris : ceux-ci commencent dessous, leur fond garde ses 32 px
static constexpr qreal MargeHaut = 4;

// Survol et appui des boutons (SubtleFillColorSecondary et
// SubtleFillColorTertiary), en sombre et en clair
static constexpr QRgb SurvolSombre = 0x0FFFFFFF;
static constexpr QRgb AppuiSombre = 0x0AFFFFFF;
static constexpr QRgb SurvolClair = 0x09000000;
static constexpr QRgb AppuiClair = 0x06000000;

// Bouton Fermer : CloseButtonColor, fond à 90 % et symbole blanc à 70 %
// quand il est enfoncé
static constexpr QRgb Fermer = 0xFFC42B1C;
static constexpr qreal FermerAppuiFond = 0.9;
static constexpr qreal FermerAppuiSymbole = 0.7;

// Symbole d'un bouton d'une fenêtre inactive : TextFillColorDisabled
// (#5DFFFFFF en sombre, #5C000000 en clair)
static constexpr qreal SymboleInactif = 0x5D / 255.0;

// Durée du survol des boutons : 150 ms dans le modèle, à l'échelle du
// facteur des animations de KDE (5/6 dans Ankh, D-052 lot 1)
static constexpr qreal DureeSurvol = 180;

// Ombre d'une fenêtre (élévation 64 : Translation.Z 128) : une ombre
// ambiante (flou 64/3, décalée de 2) et une ombre dirigée (flou 64, décalée
// de 32), à 37 % chacune en sombre, 15 % et 19 % en clair
static constexpr qreal OmbreAmbianteFlou = 64.0 / 3;
static constexpr qreal OmbreAmbianteDecalage = 2;
static constexpr qreal OmbreDirigeeFlou = 64;
static constexpr qreal OmbreDirigeeDecalage = 32;
static constexpr qreal OmbreAmbianteSombre = 0.37;
static constexpr qreal OmbreDirigeeSombre = 0.37;
static constexpr qreal OmbreAmbianteClair = 0.15;
static constexpr qreal OmbreDirigeeClair = 0.19;
// Une fenêtre inactive a une ombre moitié moins forte, comme dans Breeze
static constexpr qreal OmbreInactive = 0.5;
// Recouvrement de l'ombre sous la fenêtre (Shadow_Overlap de Breeze)
static constexpr int OmbreRecouvrement = 3;
}
