/*
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2026 Ankh
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 *
 * Boutons de la décoration d'Ankh (D-052, lot 2), dérivés de
 * kdecoration/breezebutton.cpp de Breeze 6.7.5 :
 * - réduire, agrandir et fermer : rectangles de 46 px de large sur toute la
 *   hauteur de la barre, collés au bord droit ; symboles de 10×10 dessinés
 *   d'un trait de 1 px, comme ChromeMinimize, ChromeMaximize, ChromeRestore
 *   et ChromeClose (Segoe Fluent Icons) ;
 * - survol : voile clair en sombre, sombre en clair ; Fermer : rouge #C42B1C,
 *   symbole blanc ;
 * - menu de la fenêtre : l'icône de l'application, 16 px, à 16 px du bord ;
 * - les autres boutons gardent les symboles de Breeze, réduits à 10×10.
 */

#include "ankhbouton.h"

#include "ankhmetrique.h"

#include <KColorUtils>
#include <KDecoration3/DecoratedWindow>
#include <KIconLoader>

#include <QPainter>
#include <QPainterPath>
#include <QVariantAnimation>

namespace Ankh
{
using KDecoration3::DecorationButtonType;

//__________________________________________________________________
Button::Button(DecorationButtonType type, Decoration *decoration, QObject *parent)
    : DecorationButton(type, decoration, parent)
    , m_animation(new QVariantAnimation(this))
{
    m_animation->setStartValue(0.0);
    m_animation->setEndValue(1.0);
    m_animation->setEasingCurve(QEasingCurve::InOutQuad);
    connect(m_animation, &QVariantAnimation::valueChanged, this, [this](const QVariant &value) {
        m_hover = value.toReal();
        update();
    });
    connect(this, &KDecoration3::DecorationButton::hoveredChanged, this, &Button::updateAnimationState);
    connect(decoration->window(), &KDecoration3::DecoratedWindow::activeChanged, this, [this]() {
        update();
    });
}

Button::Button(QObject *parent, const QVariantList &args)
    : Button(args.at(0).value<DecorationButtonType>(), args.at(1).value<Decoration *>(), parent)
{
    setGeometry(QRectF(QPointF(0, 0), preferredSize()));
}

Button *Button::create(DecorationButtonType type, KDecoration3::Decoration *decoration, QObject *parent)
{
    auto d = qobject_cast<Decoration *>(decoration);
    if (!d) {
        return nullptr;
    }
    auto b = new Button(type, d, parent);
    const auto w = d->window();
    switch (type) {
    case DecorationButtonType::Close:
        b->setVisible(w->isCloseable());
        connect(w, &KDecoration3::DecoratedWindow::closeableChanged, b, &Button::setVisible);
        break;
    case DecorationButtonType::Maximize:
        b->setVisible(w->isMaximizeable());
        connect(w, &KDecoration3::DecoratedWindow::maximizeableChanged, b, &Button::setVisible);
        break;
    case DecorationButtonType::Minimize:
        b->setVisible(w->isMinimizeable());
        connect(w, &KDecoration3::DecoratedWindow::minimizeableChanged, b, &Button::setVisible);
        break;
    case DecorationButtonType::ContextHelp:
        b->setVisible(w->providesContextHelp());
        connect(w, &KDecoration3::DecoratedWindow::providesContextHelpChanged, b, &Button::setVisible);
        break;
    case DecorationButtonType::Shade:
        b->setVisible(w->isShadeable());
        connect(w, &KDecoration3::DecoratedWindow::shadeableChanged, b, &Button::setVisible);
        break;
    case DecorationButtonType::Menu:
        connect(w, &KDecoration3::DecoratedWindow::iconChanged, b, [b]() {
            b->update();
        });
        break;
    default:
        break;
    }
    return b;
}

//__________________________________________________________________
QSizeF Button::preferredSize() const
{
    auto d = qobject_cast<Decoration *>(decoration());
    const qreal hauteur = (d && d->borderTop() > 0) ? d->borderTop() : Metrique::BarreDeTitre;
    switch (type()) {
    case DecorationButtonType::Menu:
        // L'icône à 16 px du bord, et la moitié de l'espace avant le titre :
        // le titre commence 8 px plus loin (Decoration::captionRect)
        return QSizeF(Metrique::IconeBord + Metrique::Icone + Metrique::IconeTitre - Metrique::TitreFin, hauteur);
    case DecorationButtonType::Spacer:
        return QSizeF(Metrique::BoutonLargeur / 2, hauteur);
    default:
        return QSizeF(Metrique::BoutonLargeur, hauteur);
    }
}

//__________________________________________________________________
void Button::updateAnimationState(bool hovered)
{
    auto d = qobject_cast<Decoration *>(decoration());
    if (!d || d->hoverDuration() <= 0) {
        m_hover = hovered ? 1.0 : 0.0;
        update();
        return;
    }
    m_animation->setDuration(d->hoverDuration());
    m_animation->setDirection(hovered ? QAbstractAnimation::Forward : QAbstractAnimation::Backward);
    if (m_animation->state() != QAbstractAnimation::Running) {
        m_animation->start();
    }
}

//__________________________________________________________________
QColor Button::backgroundColor() const
{
    auto d = qobject_cast<Decoration *>(decoration());
    if (!d || type() == DecorationButtonType::Menu || type() == DecorationButtonType::Spacer) {
        return QColor();
    }
    if (type() == DecorationButtonType::Close) {
        QColor rouge = QColor::fromRgba(Metrique::Fermer);
        rouge.setAlphaF(isPressed() ? Metrique::FermerAppuiFond : m_hover);
        return rouge;
    }
    const bool sombre = d->isDark();
    if (isPressed()) {
        return QColor::fromRgba(sombre ? Metrique::AppuiSombre : Metrique::AppuiClair);
    }
    QColor voile = QColor::fromRgba(sombre ? Metrique::SurvolSombre : Metrique::SurvolClair);
    // Un bouton à bascule enclenché (garder au-dessus…) reste voilé
    const bool enclenche = isCheckable() && isChecked() && type() != DecorationButtonType::Maximize;
    voile.setAlphaF(voile.alphaF() * (enclenche ? 1.0 : m_hover));
    return voile;
}

QColor Button::symbolColor() const
{
    auto d = qobject_cast<Decoration *>(decoration());
    if (!d) {
        return QColor();
    }
    QColor couleur = d->textColor();
    if (type() == DecorationButtonType::Close && (isPressed() || m_hover > 0)) {
        QColor blanc(Qt::white);
        if (isPressed()) {
            blanc.setAlphaF(Metrique::FermerAppuiSymbole);
            return blanc;
        }
        couleur = KColorUtils::mix(couleur, blanc, m_hover);
    }
    // Fenêtre inactive : symboles atténués, sauf au survol
    if (!d->window()->isActive()) {
        couleur.setAlphaF(couleur.alphaF() * (Metrique::SymboleInactif + (1 - Metrique::SymboleInactif) * m_hover));
    }
    return couleur;
}

//__________________________________________________________________
void Button::paint(QPainter *painter, const QRectF &repaintRegion)
{
    Q_UNUSED(repaintRegion)
    if (!decoration() || type() == DecorationButtonType::Spacer) {
        return;
    }
    painter->save();
    if (type() == DecorationButtonType::Menu) {
        paintIcon(painter);
    } else {
        paintBackground(painter);
        paintSymbol(painter);
    }
    painter->restore();
}

void Button::paintBackground(QPainter *painter) const
{
    const QColor fond = backgroundColor();
    if (fond.isValid() && fond.alpha() > 0) {
        painter->fillRect(geometry(), fond);
    }
}

void Button::paintIcon(QPainter *painter) const
{
    auto d = qobject_cast<Decoration *>(decoration());
    const auto w = decoration()->window();
    const QRectF g = geometry();
    const QRectF icone(g.left() + Metrique::IconeBord, g.center().y() - Metrique::Icone / 2, Metrique::Icone, Metrique::Icone);
    if (d) {
        painter->setOpacity(d->contentOpacity());
    }
    // Les icônes symboliques prennent la couleur du titre, comme dans Breeze
    const QPalette avant = KIconLoader::global()->customPalette();
    QPalette palette = w->palette();
    if (d) {
        palette.setColor(QPalette::WindowText, d->textColor());
    }
    KIconLoader::global()->setCustomPalette(palette);
    w->icon().paint(painter, icone.toRect());
    if (avant == QPalette()) {
        KIconLoader::global()->resetPalette();
    } else {
        KIconLoader::global()->setCustomPalette(avant);
    }
}

void Button::paintSymbol(QPainter *painter) const
{
    const QColor couleur = symbolColor();
    if (!couleur.isValid()) {
        return;
    }
    painter->setRenderHint(QPainter::Antialiasing);

    // Carré de 10×10 au centre du bouton, sur la grille des pixels
    const QRectF g = geometry();
    const QPointF o(qRound(g.center().x() - Metrique::Symbole / 2), qRound(g.center().y() - Metrique::Symbole / 2));
    QPen pen(couleur);
    pen.setWidthF(1.0);
    pen.setCapStyle(Qt::FlatCap);
    pen.setJoinStyle(Qt::MiterJoin);
    painter->setPen(pen);
    painter->setBrush(Qt::NoBrush);

    switch (type()) {
    case DecorationButtonType::Minimize:
        painter->drawLine(QPointF(o.x(), o.y() + 5.5), QPointF(o.x() + 10, o.y() + 5.5));
        return;
    case DecorationButtonType::Maximize:
        if (isChecked()) {
            // Restaurer : un carré, et le coin d'un second derrière lui
            painter->drawRoundedRect(QRectF(o.x() + 0.5, o.y() + 2.5, 7, 7), 1, 1);
            QPainterPath derriere;
            derriere.moveTo(o.x() + 2.5, o.y() + 0.5);
            derriere.lineTo(o.x() + 8.5, o.y() + 0.5);
            derriere.quadTo(o.x() + 9.5, o.y() + 0.5, o.x() + 9.5, o.y() + 1.5);
            derriere.lineTo(o.x() + 9.5, o.y() + 7.5);
            painter->drawPath(derriere);
        } else {
            painter->drawRoundedRect(QRectF(o.x() + 0.5, o.y() + 0.5, 9, 9), 1, 1);
        }
        return;
    case DecorationButtonType::Close:
        // Une diagonale de 1 px, Qt la répartit sur deux pixels à moitié
        // allumés : la croix paraissait plus pâle que les autres symboles.
        // À 1,25 px, chaque rangée a un pixel plein, comme les traits droits
        // (essai avec QPainter, 2026-10-16) ; la croix garde ses 10×10.
        pen.setWidthF(1.25);
        painter->setPen(pen);
        painter->drawLine(QPointF(o.x() + 0.25, o.y() + 0.25), QPointF(o.x() + 9.75, o.y() + 9.75));
        painter->drawLine(QPointF(o.x() + 9.75, o.y() + 0.25), QPointF(o.x() + 0.25, o.y() + 9.75));
        return;
    default:
        break;
    }

    // Autres boutons : symboles de Breeze (dessinés dans un carré de 18),
    // réduits à 10×10
    painter->translate(o);
    painter->scale(Metrique::Symbole / 18.0, Metrique::Symbole / 18.0);
    pen.setWidthF(18.0 / Metrique::Symbole);
    pen.setCapStyle(Qt::RoundCap);
    painter->setPen(pen);
    switch (type()) {
    case DecorationButtonType::OnAllDesktops:
        painter->setPen(Qt::NoPen);
        painter->setBrush(couleur);
        if (isChecked()) {
            painter->drawEllipse(QRectF(3, 3, 12, 12));
        } else {
            painter->drawPolygon(QVector<QPointF>{QPointF(6.5, 8.5), QPointF(12, 3), QPointF(15, 6), QPointF(9.5, 11.5)});
            painter->setPen(pen);
            painter->drawLine(QPointF(5.5, 7.5), QPointF(10.5, 12.5));
            painter->drawLine(QPointF(12, 6), QPointF(4.5, 13.5));
        }
        break;
    case DecorationButtonType::Shade:
        painter->drawLine(QPointF(4, 5.5), QPointF(14, 5.5));
        if (isChecked()) {
            painter->drawPolyline(QVector<QPointF>{QPointF(4, 8), QPointF(9, 13), QPointF(14, 8)});
        } else {
            painter->drawPolyline(QVector<QPointF>{QPointF(4, 13), QPointF(9, 8), QPointF(14, 13)});
        }
        break;
    case DecorationButtonType::KeepBelow:
        painter->drawPolyline(QVector<QPointF>{QPointF(4, 5), QPointF(9, 10), QPointF(14, 5)});
        painter->drawPolyline(QVector<QPointF>{QPointF(4, 9), QPointF(9, 14), QPointF(14, 9)});
        break;
    case DecorationButtonType::KeepAbove:
        painter->drawPolyline(QVector<QPointF>{QPointF(4, 9), QPointF(9, 4), QPointF(14, 9)});
        painter->drawPolyline(QVector<QPointF>{QPointF(4, 13), QPointF(9, 8), QPointF(14, 13)});
        break;
    case DecorationButtonType::ApplicationMenu:
        painter->drawLine(QPointF(3.5, 4.5), QPointF(14.5, 4.5));
        painter->drawLine(QPointF(3.5, 9), QPointF(14.5, 9));
        painter->drawLine(QPointF(3.5, 13.5), QPointF(14.5, 13.5));
        break;
    case DecorationButtonType::ContextHelp: {
        QPainterPath path;
        path.moveTo(5, 6);
        path.arcTo(QRectF(5, 3.5, 8, 5), 180, -180);
        path.cubicTo(QPointF(12.5, 9.5), QPointF(9, 7.5), QPointF(9, 11.5));
        painter->drawPath(path);
        painter->drawPoint(QPointF(9, 15));
        break;
    }
    default:
        break;
    }
}
} // namespace Ankh
