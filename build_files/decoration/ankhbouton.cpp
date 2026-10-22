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
#include <KDecoration3/ScaleHelpers>
#include <KIconLoader>

#include <QPainter>
#include <QPainterPath>
#include <QVariantAnimation>

#include <algorithm>

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
    // Le fond du bouton couvre aussi la bande de redimensionnement au-dessus
    // de lui (zone()) : chaque repeinte la couvre, sinon le survol n'y serait
    // pas dessiné (KDecoration3 ne repeint que la géométrie du bouton, et le
    // banc a mesuré un Fermer rouge de 28 px de haut au lieu de 32)
    connect(m_animation, &QVariantAnimation::valueChanged, this, [this](const QVariant &value) {
        m_hover = value.toReal();
        update(zone());
    });
    connect(this, &KDecoration3::DecorationButton::hoveredChanged, this, &Button::updateAnimationState);
    connect(this, &KDecoration3::DecorationButton::pressedChanged, this, [this]() {
        update(zone());
    });
    connect(decoration->window(), &KDecoration3::DecoratedWindow::activeChanged, this, [this]() {
        update(zone());
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
            b->update(b->zone());
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
    // Sous la bande du haut qui sert à redimensionner (Decoration::topResizeMargin)
    const qreal hauteur = (d && d->borderTop() > 0) ? d->borderTop() - d->topResizeMargin() : Metrique::BarreDeTitre;
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
        update(zone());
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
    // Fenêtre inactive : symboles atténués, sauf au survol (si son jeu de
    // couleurs ne lui donne pas un texte à elle : Decoration::fadesInactive)
    if (d->fadesInactive()) {
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
        painter->fillRect(zone(), fond);
    }
}

QRectF Button::zone() const
{
    // Le bouton et la bande du haut au-dessus de lui : son fond et son symbole
    // occupent toute la hauteur de la barre, comme dans Windows 11
    auto d = qobject_cast<Decoration *>(decoration());
    return d ? geometry().adjusted(0, -d->topResizeMargin(), 0, 0) : geometry();
}

void Button::paintIcon(QPainter *painter) const
{
    auto d = qobject_cast<Decoration *>(decoration());
    const auto w = decoration()->window();
    const QRectF g = zone();
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

    // Carré de 10×10 au centre du bouton, sur la grille des pixels de l'écran
    // (à 125 ou 150 %, un pixel logique n'en est pas un)
    const qreal echelle = decoration()->window()->scale();
    const QRectF g = zone();
    const QPointF o(KDecoration3::snapToPixelGrid(g.center().x() - Metrique::Symbole / 2, echelle),
                    KDecoration3::snapToPixelGrid(g.center().y() - Metrique::Symbole / 2, echelle));
    // Trait d'un pixel de l'écran au moins, posé au milieu des pixels : net à
    // toutes les échelles (à 100 %, un trait de 1 sur les demi-pixels)
    const qreal trait = std::max(KDecoration3::pixelSize(echelle), KDecoration3::snapToPixelGrid(1.0, echelle));
    const qreal demi = trait / 2;
    const auto px = [echelle](qreal valeur) {
        return KDecoration3::snapToPixelGrid(valeur, echelle);
    };
    QPen pen(couleur);
    pen.setWidthF(trait);
    pen.setCapStyle(Qt::FlatCap);
    pen.setJoinStyle(Qt::MiterJoin);
    painter->setPen(pen);
    painter->setBrush(Qt::NoBrush);

    switch (type()) {
    case DecorationButtonType::Minimize:
        painter->drawLine(QPointF(o.x(), o.y() + px(5) + demi), QPointF(o.x() + px(10), o.y() + px(5) + demi));
        return;
    case DecorationButtonType::Maximize:
        if (isChecked()) {
            // Restaurer : un carré, et le coin d'un second derrière lui
            painter->drawRoundedRect(QRectF(o.x() + demi, o.y() + px(2) + demi, px(8) - trait, px(8) - trait), 1, 1);
            QPainterPath derriere;
            derriere.moveTo(o.x() + px(2) + demi, o.y() + demi);
            derriere.lineTo(o.x() + px(9) - demi, o.y() + demi);
            derriere.quadTo(o.x() + px(10) - demi, o.y() + demi, o.x() + px(10) - demi, o.y() + px(1) + demi);
            derriere.lineTo(o.x() + px(10) - demi, o.y() + px(8) - demi);
            painter->drawPath(derriere);
        } else {
            painter->drawRoundedRect(QRectF(o.x() + demi, o.y() + demi, px(10) - trait, px(10) - trait), 1, 1);
        }
        return;
    case DecorationButtonType::Close: {
        // Une diagonale de 1 px, Qt la répartit sur deux pixels à moitié
        // allumés : la croix paraissait plus pâle que les autres symboles.
        // À 1,25 px, chaque rangée a un pixel plein, comme les traits droits
        // (essai avec QPainter, 2026-10-16) ; la croix garde ses 10×10.
        pen.setWidthF(trait * 1.25);
        painter->setPen(pen);
        const qreal bout = trait / 4;
        painter->drawLine(QPointF(o.x() + bout, o.y() + bout), QPointF(o.x() + px(10) - bout, o.y() + px(10) - bout));
        painter->drawLine(QPointF(o.x() + px(10) - bout, o.y() + bout), QPointF(o.x() + bout, o.y() + px(10) - bout));
        return;
    }
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
