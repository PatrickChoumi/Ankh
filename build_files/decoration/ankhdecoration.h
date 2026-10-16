/*
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2026 Ankh
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 *
 * Décoration des fenêtres d'Ankh (D-052, lot 2), dérivée de
 * kdecoration/breezedecoration.h de Breeze 6.7.5 : sans réglages ni
 * exceptions, aux mesures de Windows 11 (ankhmetrique.h).
 */

#pragma once

#include <KDecoration3/DecoratedWindow>
#include <KDecoration3/Decoration>
#include <KDecoration3/DecorationSettings>

#include <QPainterPath>
#include <QVariant>

#include <memory>

namespace KDecoration3
{
class DecorationButtonGroup;
class DecorationShadow;
}

namespace Ankh
{
class Decoration : public KDecoration3::Decoration
{
    Q_OBJECT

public:
    explicit Decoration(QObject *parent = nullptr, const QVariantList &args = QVariantList());
    ~Decoration() override;

    void paint(QPainter *painter, const QRectF &repaintRegion) override;

    //* Fond de la barre de titre
    QColor titleBarColor() const;
    //* Texte de la barre de titre, plein
    QColor textColor() const;
    //* Titre et icône : à moitié transparents quand la fenêtre est inactive
    qreal contentOpacity() const;
    //* Barre de titre sombre (survol et ombre de Windows en sombre)
    bool isDark() const;
    //* Durée du survol des boutons, en ms (0 : sans animation)
    int hoverDuration() const
    {
        return m_hoverDuration;
    }

    //* Coins arrondis : ni agrandie, ni collée à un bord de l'écran
    bool hasRoundedCorners() const;
    //* Forme de la barre de titre, pour que le survol des boutons suive le coin
    QPainterPath titleBarShape() const;

public Q_SLOTS:
    bool init() override;

private Q_SLOTS:
    void reconfigure();
    void recalculateBorders();
    void updateTitleBar();
    void updateButtonsGeometry();
    void updateShadow();

private:
    QRectF captionRect() const;
    void paintTitleBar(QPainter *painter, const QRectF &repaintRegion);
    std::shared_ptr<KDecoration3::DecorationShadow> createShadow(bool active, bool dark) const;

    bool isMaximized() const;
    bool isTopEdge() const;

    KDecoration3::DecorationButtonGroup *m_leftButtons = nullptr;
    KDecoration3::DecorationButtonGroup *m_rightButtons = nullptr;
    int m_hoverDuration = 150;
};
}
