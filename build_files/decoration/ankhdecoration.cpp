/*
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2018 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
 * SPDX-FileCopyrightText: 2021 Paul McAuley <kde@paulmcauley.com>
 * SPDX-FileCopyrightText: 2026 Ankh
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 *
 * Décoration des fenêtres d'Ankh (D-052, lot 2), dérivée de
 * kdecoration/breezedecoration.cpp de Breeze 6.7.5. Ce qui change :
 * - barre de titre de 32 px, de la couleur de la fenêtre, sans bords
 *   visibles : un contour de 1 px, et une marge invisible pour redimensionner ;
 * - icône de 16 px à 16 px du bord, titre 16 px plus loin, aligné à gauche ;
 *   les deux à moitié transparents quand la fenêtre est inactive ;
 * - coins de 8 px, carrés quand la fenêtre est agrandie ou collée à un bord ;
 * - ombre de Windows 11 : ambiante et dirigée ;
 * - boutons rectangulaires de 46×32 (ankhbouton.cpp).
 */

#include "ankhdecoration.h"

#include "ankhbouton.h"
#include "ankhmetrique.h"
#include "ankhombre.h"

#include <KDecoration3/DecorationButtonGroup>
#include <KDecoration3/DecorationShadow>
#include <KDecoration3/ScaleHelpers>

#include <KColorScheme>
#include <KColorUtils>
#include <KConfigGroup>
#include <KPluginFactory>
#include <KSharedConfig>

#include <QDBusConnection>
#include <QFontMetricsF>
#include <QPainter>
#include <QTimer>
#include <QtMath>

K_PLUGIN_FACTORY_WITH_JSON(AnkhDecorationFactory, "ankh.json", registerPlugin<Ankh::Decoration>(); registerPlugin<Ankh::Button>();)

namespace Ankh
{
using KDecoration3::ColorGroup;
using KDecoration3::ColorRole;

//________________________________________________________________
// Ombres partagées par toutes les fenêtres : [sombre][active]
static int g_decorations = 0;
static std::shared_ptr<KDecoration3::DecorationShadow> g_ombres[2][2];

Decoration::Decoration(QObject *parent, const QVariantList &args)
    : KDecoration3::Decoration(parent, args)
{
    g_decorations++;
}

Decoration::~Decoration()
{
    g_decorations--;
    if (g_decorations == 0) {
        for (auto &paire : g_ombres) {
            for (auto &ombre : paire) {
                ombre.reset();
            }
        }
    }
}

//________________________________________________________________
QColor Decoration::titleBarColor() const
{
    return window()->color(window()->isActive() ? ColorGroup::Active : ColorGroup::Inactive, ColorRole::TitleBar);
}

QColor Decoration::textColor() const
{
    return window()->color(window()->isActive() ? ColorGroup::Active : ColorGroup::Inactive, ColorRole::Foreground);
}

bool Decoration::fadesInactive() const
{
    // Windows 11 atténue l'icône et le titre d'une fenêtre inactive
    // (TitleBarDeactivatedOpacity). Si le jeu de couleurs prévoit déjà un
    // texte pour les fenêtres inactives (barre de titre teintée d'accent, par
    // exemple), il est pris tel quel : l'atténuer le rendrait illisible.
    return !window()->isActive()
        && window()->color(ColorGroup::Active, ColorRole::Foreground) == window()->color(ColorGroup::Inactive, ColorRole::Foreground);
}

qreal Decoration::contentOpacity() const
{
    return fadesInactive() ? Metrique::OpaciteInactive : 1.0;
}

qreal Decoration::topResizeMargin() const
{
    return isTopEdge() ? 0 : KDecoration3::snapToPixelGrid(Metrique::MargeHaut, window()->scale());
}

bool Decoration::isDark() const
{
    return KColorUtils::luma(titleBarColor()) < 0.5;
}

bool Decoration::isMaximized() const
{
    return window()->isMaximized();
}

bool Decoration::isTopEdge() const
{
    return window()->isMaximizedVertically() || window()->adjacentScreenEdges().testFlag(Qt::TopEdge);
}

bool Decoration::hasRoundedCorners() const
{
    return !isMaximized() && window()->adjacentScreenEdges() == Qt::Edges() && settings()->isAlphaChannelSupported();
}

QPainterPath Decoration::titleBarShape() const
{
    QPainterPath forme;
    const QRectF barre(QPointF(0, 0), QSizeF(size().width(), borderTop()));
    // Même rayon que le contour et le bas de la fenêtre, sur la grille des pixels
    const qreal rayon = KDecoration3::snapToPixelGrid(Metrique::Rayon, window()->scale());
    if (!hasRoundedCorners()) {
        forme.addRect(barre);
    } else if (window()->isShaded()) {
        forme.addRoundedRect(barre, rayon, rayon);
    } else {
        // Coins arrondis en haut seulement
        forme.addRoundedRect(barre.adjusted(0, 0, 0, rayon), rayon, rayon);
        forme = forme.intersected([&barre] {
            QPainterPath p;
            p.addRect(barre);
            return p;
        }());
    }
    return forme;
}

//________________________________________________________________
bool Decoration::init()
{
    // Facteur des animations : relu quand les réglages de KDE changent
    QDBusConnection::sessionBus().connect(QString(),
                                          QStringLiteral("/KGlobalSettings"),
                                          QStringLiteral("org.kde.KGlobalSettings"),
                                          QStringLiteral("notifyChange"),
                                          this,
                                          SLOT(reconfigure()));

    auto s = settings();
    connect(s.get(), &KDecoration3::DecorationSettings::reconfigured, this, &Decoration::reconfigure);
    connect(s.get(), &KDecoration3::DecorationSettings::fontChanged, this, &Decoration::recalculateBorders);

    const auto w = window();
    connect(w, &KDecoration3::DecoratedWindow::activeChanged, this, [this]() {
        recalculateBorders();
        updateShadow();
        update();
    });
    connect(w, &KDecoration3::DecoratedWindow::captionChanged, this, [this]() {
        update(titleBar());
    });
    connect(w, &KDecoration3::DecoratedWindow::paletteChanged, this, [this]() {
        recalculateBorders();
        updateShadow();
        update();
    });
    // Agrandie, collée à un bord de l'écran ou enroulée : bords, coins,
    // boutons et barre de titre changent
    const auto geometrie = [this]() {
        recalculateBorders();
        updateButtonsGeometry();
        updateTitleBar();
    };
    connect(w, &KDecoration3::DecoratedWindow::adjacentScreenEdgesChanged, this, geometrie);
    connect(w, &KDecoration3::DecoratedWindow::maximizedHorizontallyChanged, this, geometrie);
    connect(w, &KDecoration3::DecoratedWindow::maximizedVerticallyChanged, this, geometrie);
    connect(w, &KDecoration3::DecoratedWindow::shadedChanged, this, geometrie);
    // Agrandie : pas d'ombre, barre de titre opaque (comme Windows 11 et Breeze)
    connect(w, &KDecoration3::DecoratedWindow::maximizedChanged, this, [this]() {
        setOpaque(isMaximized());
        updateShadow();
    });
    connect(w, &KDecoration3::DecoratedWindow::widthChanged, this, &Decoration::updateTitleBar);
    connect(w, &KDecoration3::DecoratedWindow::widthChanged, this, &Decoration::updateButtonsGeometry);
    connect(w, &KDecoration3::DecoratedWindow::nextScaleChanged, this, &Decoration::recalculateBorders);
    // Nouvelle hauteur de la barre (police, échelle) : la barre et les boutons
    // la suivent quand elle s'applique
    connect(this, &KDecoration3::Decoration::bordersChanged, this, &Decoration::updateTitleBar);
    connect(this, &KDecoration3::Decoration::bordersChanged, this, &Decoration::updateButtonsGeometry);

    m_leftButtons = new KDecoration3::DecorationButtonGroup(KDecoration3::DecorationButtonGroup::Position::Left, this, &Button::create);
    m_rightButtons = new KDecoration3::DecorationButtonGroup(KDecoration3::DecorationButtonGroup::Position::Right, this, &Button::create);
    // Boutons choisis dans les réglages : les groupes les recréent, puis leur
    // place est recalculée (une fois les nouveaux boutons créés, comme Breeze)
    connect(s.get(), &KDecoration3::DecorationSettings::decorationButtonsLeftChanged, this, &Decoration::updateButtonsGeometryDelayed);
    connect(s.get(), &KDecoration3::DecorationSettings::decorationButtonsRightChanged, this, &Decoration::updateButtonsGeometryDelayed);
    // Un bouton qui apparaît ou disparaît (Agrandir d'une fenêtre de taille
    // fixe…) change la largeur d'un groupe : celui de droite reste collé au bord
    connect(m_leftButtons, &KDecoration3::DecorationButtonGroup::geometryChanged, this, &Decoration::updateButtonsGeometryDelayed);
    connect(m_rightButtons, &KDecoration3::DecorationButtonGroup::geometryChanged, this, &Decoration::updateButtonsGeometryDelayed);
    setOpaque(isMaximized());

    reconfigure();
    updateTitleBar();
    updateButtonsGeometry();
    return true;
}

//________________________________________________________________
void Decoration::reconfigure()
{
    const KConfigGroup kde(KSharedConfig::openConfig(), QStringLiteral("KDE"));
    m_hoverDuration = std::max(0, int(kde.readEntry("AnimationDurationFactor", 1.0) * Metrique::DureeSurvol));
    recalculateBorders();
    updateButtonsGeometry();
    updateShadow();
}

//________________________________________________________________
void Decoration::recalculateBorders()
{
    const qreal echelle = window()->nextScale();

    // Aucun bord visible : seulement la barre de titre (sa hauteur, ou celle
    // du texte si la police est plus grande)
    const QFontMetricsF fm(settings()->font());
    const qreal haut = KDecoration3::snapToPixelGrid(std::max(Metrique::BarreDeTitre, fm.height()), echelle);
    setBorders(QMarginsF(0, haut, 0, 0));

    // Marge invisible pour redimensionner, sauf contre un bord de l'écran
    const qreal marge = KDecoration3::snapToPixelGrid(Metrique::BordInvisible, echelle);
    const auto bords = window()->adjacentScreenEdges();
    const bool largeur = window()->isMaximizedHorizontally();
    const bool hauteur = window()->isMaximizedVertically();
    setResizeOnlyBorders(QMarginsF(largeur || bords.testFlag(Qt::LeftEdge) ? 0 : marge,
                                   0,
                                   largeur || bords.testFlag(Qt::RightEdge) ? 0 : marge,
                                   hauteur || bords.testFlag(Qt::BottomEdge) ? 0 : marge));

    // Coins : le contenu de la fenêtre est arrondi en bas, la barre de titre
    // est arrondie en haut (paintTitleBar)
    const qreal rayon = hasRoundedCorners() ? KDecoration3::snapToPixelGrid(Metrique::Rayon, echelle) : 0;
    setBorderRadius(KDecoration3::BorderRadius(0, 0, rayon, rayon));

    // Contour de 1 px, comme celui de Breeze
    if (isMaximized()) {
        setBorderOutline(KDecoration3::BorderOutline());
    } else {
        const auto couleur = KColorUtils::mix(window()->color(window()->isActive() ? ColorGroup::Active : ColorGroup::Inactive, ColorRole::Frame),
                                              window()->palette().text().color(),
                                              KColorScheme::frameContrast());
        const qreal epaisseur = std::max(KDecoration3::pixelSize(echelle), KDecoration3::snapToPixelGrid(1, echelle));
        setBorderOutline(KDecoration3::BorderOutline(epaisseur, couleur, KDecoration3::BorderRadius(rayon)));
    }
}

//________________________________________________________________
void Decoration::updateTitleBar()
{
    // Les 4 px du haut restent pour redimensionner par le bord supérieur,
    // sauf contre le haut de l'écran
    const qreal marge = topResizeMargin();
    setTitleBar(QRectF(0, marge, size().width(), borderTop() - marge));
}

//________________________________________________________________
void Decoration::updateButtonsGeometry()
{
    if (!m_leftButtons || !m_rightButtons) {
        return;
    }
    for (auto *bouton : m_leftButtons->buttons() + m_rightButtons->buttons()) {
        auto b = static_cast<Button *>(bouton);
        b->setGeometry(QRectF(QPointF(0, 0), b->preferredSize()));
    }
    // Boutons collés les uns aux autres et aux bords de la fenêtre, sous la
    // bande qui sert à redimensionner
    const qreal marge = topResizeMargin();
    m_leftButtons->setSpacing(0);
    m_leftButtons->setPos(QPointF(0, marge));
    m_rightButtons->setSpacing(0);
    m_rightButtons->setPos(QPointF(size().width() - m_rightButtons->geometry().width(), marge));
    update();
}

void Decoration::updateButtonsGeometryDelayed()
{
    QTimer::singleShot(0, this, &Decoration::updateButtonsGeometry);
}

//________________________________________________________________
QRectF Decoration::captionRect() const
{
    // À 16 px du bord sans icône ; avec l'icône (bouton du menu), 16 px après
    // elle : la fin du groupe de gauche, plus 8 px
    const qreal gauche = m_leftButtons->buttons().isEmpty() ? Metrique::IconeBord : m_leftButtons->geometry().right() + Metrique::TitreFin;
    const qreal droite = m_rightButtons->buttons().isEmpty() ? size().width() - Metrique::TitreFin : m_rightButtons->geometry().left() - Metrique::TitreFin;
    return QRectF(gauche, 0, std::max<qreal>(0, droite - gauche), borderTop());
}

//________________________________________________________________
void Decoration::paint(QPainter *painter, const QRectF &repaintRegion)
{
    paintTitleBar(painter, repaintRegion);
}

void Decoration::paintTitleBar(QPainter *painter, const QRectF &repaintRegion)
{
    const QRectF barre(QPointF(0, 0), QSizeF(size().width(), borderTop()));
    if (!barre.intersects(repaintRegion)) {
        return;
    }

    painter->save();
    painter->setRenderHint(QPainter::Antialiasing);
    painter->setPen(Qt::NoPen);
    painter->setBrush(titleBarColor());
    painter->drawPath(titleBarShape());
    painter->restore();

    // Titre, en légende (police des barres de titre, D-052 lot 1), coupé à la fin
    const QRectF rect = captionRect();
    painter->save();
    painter->setOpacity(contentOpacity());
    painter->setFont(settings()->font());
    painter->setPen(textColor());
    const QString titre = painter->fontMetrics().elidedText(window()->caption(), Qt::ElideRight, rect.width());
    painter->drawText(rect, Qt::AlignVCenter | Qt::AlignLeft | Qt::TextSingleLine, titre);
    painter->restore();

    // Boutons, dans la forme de la barre : le rouge du bouton Fermer suit le coin
    painter->save();
    painter->setClipPath(titleBarShape(), Qt::IntersectClip);
    m_leftButtons->paint(painter, repaintRegion);
    m_rightButtons->paint(painter, repaintRegion);
    painter->restore();
}

//________________________________________________________________
void Decoration::updateShadow()
{
    // Agrandie, la fenêtre n'a pas d'ombre, comme dans Windows 11 : elle
    // déborderait sur un écran voisin
    if (isMaximized()) {
        setShadow(nullptr);
        return;
    }
    const bool sombre = isDark();
    const bool active = window()->isActive();
    auto &ombre = g_ombres[sombre][active];
    if (!ombre) {
        ombre = createShadow(active, sombre);
    }
    setShadow(ombre);
}

std::shared_ptr<KDecoration3::DecorationShadow> Decoration::createShadow(bool active, bool dark) const
{
    const qreal force = active ? 1.0 : Metrique::OmbreInactive;
    QColor ambiante(Qt::black);
    ambiante.setAlphaF((dark ? Metrique::OmbreAmbianteSombre : Metrique::OmbreAmbianteClair) * force);
    QColor dirigee(Qt::black);
    dirigee.setAlphaF((dark ? Metrique::OmbreDirigeeSombre : Metrique::OmbreDirigeeClair) * force);

    // Les deux ombres sont placées de part et d'autre de leur décalage moyen,
    // pour que la texture reste centrée (comme les ombres de Breeze)
    const QPoint decalage(0, qRound((Metrique::OmbreAmbianteDecalage + Metrique::OmbreDirigeeDecalage) / 2));
    const QPointF decalageAmbiante(0, Metrique::OmbreAmbianteDecalage - decalage.y());
    const QPointF decalageDirigee(0, Metrique::OmbreDirigeeDecalage - decalage.y());

    const QSize boite = BoxShadowRenderer::calculateMinimumBoxSize(qCeil(Metrique::OmbreDirigeeFlou));
    BoxShadowRenderer rendu;
    rendu.setBorderRadius(Metrique::Rayon + 0.5);
    rendu.setBoxSize(boite);
    rendu.addShadow(decalageAmbiante, Metrique::OmbreAmbianteFlou, ambiante);
    rendu.addShadow(decalageDirigee, Metrique::OmbreDirigeeFlou, dirigee);
    QImage texture = rendu.render();

    // Le dedans de l'ombre est retiré : il serait vu à travers une fenêtre
    // transparente
    QPainter painter(&texture);
    painter.setRenderHint(QPainter::Antialiasing);
    const QRectF dehors = texture.rect();
    QRectF rectBoite(QPoint(0, 0), boite);
    rectBoite.moveCenter(dehors.center());
    // Marges entières : une demi-unité ferait une ligne floue au bord de l'ombre
    const QMarginsF marges(qRound(rectBoite.left() - dehors.left() - Metrique::OmbreRecouvrement - decalage.x()),
                           qRound(rectBoite.top() - dehors.top() - Metrique::OmbreRecouvrement - decalage.y()),
                           qRound(dehors.right() - rectBoite.right() - Metrique::OmbreRecouvrement + decalage.x()),
                           qRound(dehors.bottom() - rectBoite.bottom() - Metrique::OmbreRecouvrement + decalage.y()));
    QRectF dedans = dehors - marges;
    dedans.adjust(2, 2, -2, -2);
    painter.setPen(Qt::NoPen);
    painter.setBrush(Qt::black);
    painter.setCompositionMode(QPainter::CompositionMode_DestinationOut);
    painter.drawRoundedRect(dedans, Metrique::Rayon + 0.5, Metrique::Rayon + 0.5);
    painter.end();

    auto ombre = std::make_shared<KDecoration3::DecorationShadow>();
    ombre->setPadding(marges);
    ombre->setInnerShadowRect(QRectF(dehors.center(), QSizeF(1, 1)));
    ombre->setShadow(texture);
    return ombre;
}
} // namespace Ankh

#include "ankhdecoration.moc"
