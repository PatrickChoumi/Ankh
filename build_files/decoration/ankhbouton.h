/*
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2026 Ankh
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 *
 * Boutons de la décoration d'Ankh (D-052, lot 2), dérivés de
 * kdecoration/breezebutton.h de Breeze 6.7.5 : rectangles de 46×32 au lieu
 * de cercles, symboles de Windows 11 (ankhmetrique.h).
 */

#pragma once

#include "ankhdecoration.h"

#include <KDecoration3/DecorationButton>

class QVariantAnimation;

namespace Ankh
{
class Button : public KDecoration3::DecorationButton
{
    Q_OBJECT

public:
    //* Pour la création par KPluginFactory (aperçu du module des décorations)
    explicit Button(QObject *parent, const QVariantList &args);

    //* Pour les groupes de boutons de la décoration
    static Button *create(KDecoration3::DecorationButtonType type, KDecoration3::Decoration *decoration, QObject *parent);

    void paint(QPainter *painter, const QRectF &repaintRegion) override;

    QSizeF preferredSize() const;
    //* Le bouton et la bande du haut au-dessus de lui
    QRectF zone() const;

private Q_SLOTS:
    void updateAnimationState(bool hovered);

private:
    explicit Button(KDecoration3::DecorationButtonType type, Decoration *decoration, QObject *parent = nullptr);

    void paintBackground(QPainter *painter) const;
    void paintSymbol(QPainter *painter) const;
    void paintIcon(QPainter *painter) const;
    QColor backgroundColor() const;
    QColor symbolColor() const;

    QVariantAnimation *m_animation;
    //* Avancement du survol, de 0 à 1
    qreal m_hover = 0;
};
}
