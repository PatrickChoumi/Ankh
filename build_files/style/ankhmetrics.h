/*
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2020 Noah Davis <noahadvs@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QtGlobal>

namespace Ankh
{
//* standard pen widths
struct PenWidth {
    /* Using 1 instead of slightly more than 1 causes symbols drawn with
     * pen strokes to look skewed. The exact amount added does not matter
     * as long as it isn't too visible. Even with QPen::setCosmetic(true),
     * 1px pen widths still look slightly worse.
     */
    // The standard pen stroke width for symbols.
    static constexpr qreal Symbol = 1.001;

    // The standard pen stroke width for frames.
    static constexpr qreal Frame = 1.001;

    // The standard pen stroke width for shadows.
    static constexpr qreal Shadow = 1.001;

    // A value for pen width arguments to make it clear that there is no pen stroke
    static constexpr int NoPen = 0;
};

//* metrics
struct Metrics {
    // general
    static constexpr int ArrowSize = 10;
    static constexpr int SmallArrowSize = 5;

    // frames
    static constexpr int Frame_FrameWidth = 2;
    // Ankh (D-052, lot 3) : rayon des contrôles de Windows 11
    // (ControlCornerRadius 4, CommonStyles/CornerRadius_themeresources.xaml de
    // WinUI) ; 5 dans Breeze
    static constexpr int Frame_FrameRadius = 4;

    // Ankh : hauteur minimale des champs, des listes déroulantes, des boutons et
    // des cases à cocher avec leur texte (TextControlThemeMinHeight 32,
    // ComboBoxMinHeight 32, CheckBoxHeight 32 ; un bouton de Windows mesure 32
    // avec son texte de 14 px : ButtonPadding 11,5,11,6 et un bord de 1)
    static constexpr int Control_MinHeight = 32;

    // layout
    static constexpr int Layout_TopLevelMarginWidth = 10;
    static constexpr int Layout_ChildMarginWidth = 6;
    static constexpr int Layout_DefaultSpacing = 6;

    // line editors
    static constexpr int LineEdit_FrameWidth = 6;

    // menu items
    static constexpr int Menu_FrameWidth = 0;
    static constexpr int MenuItem_MarginWidth = 4;
    static constexpr int MenuItem_HighlightGap = 4;
    static constexpr int MenuItem_ExtraLeftMargin = 4;
    static constexpr int MenuItem_MarginHeight = 4;
    static constexpr int MenuItem_ItemSpacing = 2;
    static constexpr int MenuItem_AcceleratorSpace = 16;
    static constexpr int MenuItem_TextLeftMargin = 8;

    // combobox
    static constexpr int ComboBox_FrameWidth = 6;
    static constexpr int ComboBox_ItemMarginWidth = 3;

    // spinbox
    static constexpr int SpinBox_FrameWidth = LineEdit_FrameWidth;
    static constexpr int SpinBox_ArrowButtonWidth = 20;

    // groupbox title margin
    static constexpr int GroupBox_TitleMarginWidth = 4;

    // buttons
    static constexpr int Button_MinWidth = 80;
    // Ankh : marges d'un bouton, bord compris (Frame_FrameWidth, 2) : 12 sur les
    // côtés comme Windows (ButtonPadding 11 et un bord de 1) ; en hauteur, la
    // hauteur minimale de 32 l'emporte ; 6 dans les deux sens dans Breeze
    static constexpr int Button_MarginWidth = 10;
    static constexpr int Button_MarginHeight = 4;
    static constexpr int Button_ItemSpacing = 4;

    // tool buttons
    static constexpr int ToolButton_MarginWidth = 6;
    static constexpr int ToolButton_ItemSpacing = 4;
    static constexpr int ToolButton_InlineIndicatorWidth = 12;

    // menu button indicator
    static constexpr int MenuButton_IndicatorWidth = 20;

    // checkboxes and radio buttons
    static constexpr int CheckBox_Size = 20;
    static constexpr int CheckBox_FocusMarginWidth = 2;
    static constexpr int CheckBox_ItemSpacing = 4;
    // Ankh : case de 20 visible et coins de 4, comme Windows 11 (CheckBoxSize,
    // ControlCornerRadius) ; dans Breeze, la case visible mesure 16
    static constexpr int CheckBox_Radius = Frame_FrameRadius;
    // Ankh : rond d'un bouton radio choisi (RadioButtonCheckGlyphSize 12, 14 au
    // survol et 10 à l'appui) et point d'une poignée de curseur
    // (SliderInnerThumbWidth 12), CommonStyles/RadioButton_ et
    // Slider_themeresources.xaml de WinUI
    static constexpr int RadioButton_GlyphSize = 12;
    static constexpr int Slider_InnerThumbSize = 12;

    // menubar items
    static constexpr int MenuBarItem_MarginWidth = 10;
    static constexpr int MenuBarItem_MarginHeight = 6;

    // scrollbars
    // Ankh : barre de 12 et poignée de 6, comme Windows 11 (ScrollBarSize 12,
    // ScrollBarThumbStrokeThickness 6, CommonStyles/ScrollBar_themeresources.xaml) ;
    // 21 et 8 dans Breeze
    static constexpr int ScrollBar_Extend = 12;
    static constexpr int ScrollBar_SliderWidth = 6;
    static constexpr int ScrollBar_MinSliderHeight = 20;
    static constexpr int ScrollBar_NoButtonHeight = 3;
    static constexpr int ScrollBar_SingleButtonHeight = ScrollBar_Extend;
    static constexpr int ScrollBar_DoubleButtonHeight = 2 * ScrollBar_Extend;

    // toolbars
    static constexpr int ToolBar_FrameWidth = 0;
    static constexpr int ToolBar_HandleExtent = 10;
    static constexpr int ToolBar_HandleWidth = 6;
    static constexpr int ToolBar_SeparatorWidth = 8;
    static constexpr int ToolBar_ExtensionWidth = 20;
    static constexpr int ToolBar_ItemMargin = 6;
    static constexpr int ToolBar_ItemSpacing = 0;
    static constexpr int ToolBar_SeparatorVerticalMargin = 2;

    // progressbars
    static constexpr int ProgressBar_BusyIndicatorSize = 14;
    // Ankh : 3 comme Windows 11 (ProgressBarMinHeight,
    // ProgressBar/ProgressBar_themeresources.xaml) ; 6 dans Breeze
    static constexpr int ProgressBar_Thickness = 3;
    static constexpr int ProgressBar_ItemSpacing = 4;

    // mdi title bar
    static constexpr int TitleBar_MarginWidth = 4;

    // sliders
    static constexpr int Slider_TickLength = 8;
    static constexpr int Slider_TickMarginWidth = 2;
    // Ankh : rail de 4 et poignée de 18, comme Windows 11 (SliderTrackThemeHeight
    // et SliderHorizontalThumbWidth, CommonStyles/Slider_themeresources.xaml) ;
    // 6 et 20 dans Breeze
    static constexpr int Slider_GrooveThickness = 4;
    static constexpr int Slider_ControlThickness = 18;

    // tabbar
    static constexpr int TabBar_TabMarginHeight = 4;
    static constexpr int TabBar_TabMarginWidth = 8;
    static constexpr int TabBar_TabMinWidth = 80;
    static constexpr int TabBar_TabMinHeight = 30;
    static constexpr int TabBar_StaticTabMinHeight = 34;
    static constexpr int TabBar_TabItemSpacing = 8;
    static constexpr int TabBar_TabOverlap = 1;
    static constexpr int TabBar_BaseOverlap = 2;
    static constexpr int TabBar_ActiveEffectSize = 3;

    // tab widget
    static constexpr int TabWidget_MarginWidth = 3;

    // toolbox
    static constexpr int ToolBox_TabMinWidth = 80;
    static constexpr int ToolBox_TabItemSpacing = 4;
    static constexpr int ToolBox_TabMarginWidth = 8;

    // tooltips
    static constexpr int ToolTip_FrameWidth = 3;

    // list headers
    static constexpr int Header_MarginWidth = 6;
    static constexpr int Header_ItemSpacing = 4;
    static constexpr int Header_ArrowSize = ArrowSize;

    // tree view
    static constexpr int ItemView_ArrowSize = ArrowSize;
    static constexpr int ItemView_ItemMarginLeft = 2;
    static constexpr int ItemView_ItemMarginRight = 2;
    // Normal margin height is 2 to have rows spaced 4
    // First and last items will have a bigger top/bottom margin for consistent borders with the outside frame
    static constexpr int ItemView_FirstItemTopMarginHeight = 2;
    static constexpr int ItemView_ItemMarginTop = 1;
    static constexpr int ItemView_ItemMarginBottom = 1;
    static constexpr int ItemView_ItemPaddingWidth = 2;
    static constexpr int ItemView_ItemPaddingHeight = 2;
    static constexpr int SidePanel_ItemMarginWidth = 4;

    // splitter
    static constexpr int Splitter_SplitterWidth = 1;

    // shadow dimensions
    static constexpr int Shadow_Overlap = 2;

    // Value used to blend background and foreground,
    // used for hover effects and similar.
    static constexpr qreal Blend_Value = 0.3;

    static constexpr qreal Focus_LightenColorValue = 110;
};
}
