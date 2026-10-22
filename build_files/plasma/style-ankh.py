#!/usr/bin/env python3
"""Style Plasma « Ankh » (D-052, lot 4), dessiné aux mesures de Windows 11.

Un style Plasma est un dossier de SVG découpés en neuf morceaux (coins,
bords, centre) que Plasma étire à la taille de chaque volet ou bouton
(FrameSvg de KSvg). Ce script écrit les SVG que le style d'Ankh remplace ;
tout le reste vient de Breeze (FallbackTheme, plasmarc) :
- dialogs/background (et sa variante translucent/, prise quand le flou
  est actif) : volets et menus, coins de 8 (OverlayCornerRadius de WinUI),
  contour de 1 px ;
- widgets/tooltip : infobulles, coins de 4 (ControlCornerRadius), contour
  de 1 px ;
- widgets/panel-background : la barre, translucide à 60 % (valeur
  d'AnduinOS, D-052), un trait de 1 px en haut, sans ombre (la barre de
  Windows 11 n'en a pas) ;
- widgets/tasks : les boutons de la barre des tâches de Windows 11 : un
  carré arrondi de 40×40 au survol et sous l'application active, un trait
  d'accent de 16×3 sous elle, un tiret de 6×3 sous les autres applications
  ouvertes, et des icônes de 24 px dans une barre de 48 (marges de 12).

Les ombres des volets et des infobulles sont celles de Breeze, recopiées
depuis les SVG installés dans l'image : elles suivent ses versions.

Chaque forme est découpée en morceaux par calcul (polygones, arcs à 24
segments par quart de cercle) : Qt ignore les découpes (clip-path) quand
il mesure un élément, et la taille de chaque morceau doit être exacte. Un
rectangle sans remplissage donne à chaque morceau sa taille, comme dans
les SVG de Breeze.

Usage : style-ankh.py <dossier du style Breeze installé> <dossier du style d'Ankh>
"""

import gzip
import math
import pathlib
import sys
import xml.etree.ElementTree as ET

SVG = "http://www.w3.org/2000/svg"

FEUILLE = """
.ColorScheme-Text { color:#232629; stop-color:#232629; }
.ColorScheme-Background { color:#eff0f1; stop-color:#eff0f1; }
.ColorScheme-Highlight { color:#3daee9; stop-color:#3daee9; }
.ColorScheme-NeutralText { color:#f67400; stop-color:#f67400; }
"""

MORCEAUX = ("topleft", "top", "topright", "left", "center", "right", "bottomleft", "bottom", "bottomright")


def arrondi(x0, y0, x1, y1, r, pas=24):
    """Rectangle arrondi en polygone, sens horaire."""
    points = []
    for cx, cy, debut in ((x1 - r, y0 + r, -90), (x1 - r, y1 - r, 0), (x0 + r, y1 - r, 90), (x0 + r, y0 + r, 180)):
        for i in range(pas + 1):
            a = math.radians(debut + 90 * i / pas)
            points.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return points


def pastille(x0, y0, x1, y1):
    """Trait aux bouts arrondis (rayon : la moitié de son épaisseur)."""
    return arrondi(x0, y0, x1, y1, (y1 - y0) / 2)


def decouper(points, x0, y0, x1, y1):
    """Polygone découpé par un rectangle (Sutherland-Hodgman)."""
    def couper(pts, dedans, croisement):
        sortie = []
        for i, p in enumerate(pts):
            q = pts[i - 1]
            if dedans(p):
                if not dedans(q):
                    sortie.append(croisement(q, p))
                sortie.append(p)
            elif dedans(q):
                sortie.append(croisement(q, p))
        return sortie

    def en_x(xx):
        return lambda q, p: (xx, q[1] + (p[1] - q[1]) * (xx - q[0]) / (p[0] - q[0]))

    def en_y(yy):
        return lambda q, p: (q[0] + (p[0] - q[0]) * (yy - q[1]) / (p[1] - q[1]), yy)

    for dedans, croisement in ((lambda p: p[0] >= x0, en_x(x0)), (lambda p: p[0] <= x1, en_x(x1)),
                               (lambda p: p[1] >= y0, en_y(y0)), (lambda p: p[1] <= y1, en_y(y1))):
        if not points:
            break
        points = couper(points, dedans, croisement)
    return points


def chemin(polygones, dx, dy):
    morceaux = []
    for pts in polygones:
        if len(pts) >= 3:
            morceaux.append("M" + " L".join(f"{x + dx:.3f},{y + dy:.3f}" for x, y in pts) + " Z")
    return " ".join(morceaux)


class Planche:
    """Un SVG dont les éléments sont rangés en lignes, sans se toucher."""

    def __init__(self, y0=0):
        self.elements = []
        self.x = 0
        self.y = y0
        self.hauteur_ligne = 0
        self.largeur = 0

    def place(self, largeur, hauteur):
        if self.x and self.x + largeur > 600:
            self.x = 0
            self.y += self.hauteur_ligne + 4
            self.hauteur_ligne = 0
        origine = (self.x, self.y)
        self.x += largeur + 4
        self.largeur = max(self.largeur, self.x)
        self.hauteur_ligne = max(self.hauteur_ligne, hauteur)
        return origine

    def ajouter(self, xml):
        self.elements.append(xml)

    def cadre(self, prefixe, gauche, haut, droite, bas, formes, milieu=4):
        """Les neuf morceaux d'un cadre. gauche, haut, droite, bas : taille des
        bords ; formes : (polygones, classe, opacité), dans un cadre complet de
        (gauche + milieu + droite) × (haut + milieu + bas)."""
        xs = (0, gauche, gauche + milieu, gauche + milieu + droite)
        ys = (0, haut, haut + milieu, haut + milieu + bas)
        nom = (prefixe + "-") if prefixe else ""
        for ligne in range(3):
            for colonne in range(3):
                x0, x1, y0, y1 = xs[colonne], xs[colonne + 1], ys[ligne], ys[ligne + 1]
                w, h = x1 - x0, y1 - y0
                if w <= 0 or h <= 0:
                    continue
                ox, oy = self.place(w, h)
                dx, dy = ox - x0, oy - y0
                contenu = [f'<rect x="{ox}" y="{oy}" width="{w}" height="{h}" fill="none"/>']
                for polygones, classe, opacite in formes:
                    d = chemin([decouper(p, x0, y0, x1, y1) for p in polygones], dx, dy)
                    if d:
                        attribut_classe = f' class="ColorScheme-{classe}" fill="currentColor"' if classe else ' fill="#000000"'
                        contenu.append(f'<path d="{d}"{attribut_classe} fill-rule="evenodd" opacity="{opacite:g}"/>')
                self.ajouter(f'<g id="{nom}{MORCEAUX[ligne * 3 + colonne]}">' + "".join(contenu) + "</g>")

    def marges(self, prefixe, haut, bas, gauche, droite, nom="hint"):
        p = (prefixe + "-") if prefixe else ""
        for cote, w, h in (("top", 4, haut), ("bottom", 4, bas), ("left", gauche, 4), ("right", droite, 4)):
            ox, oy = self.place(max(w, 1e-8), max(h, 1e-8))
            self.ajouter(f'<rect id="{p}{nom}-{cote}-margin" x="{ox}" y="{oy}" width="{w}" height="{h}" fill="#ff00ff"/>')

    def texte(self, extra_defs="", extra="", largeur_min=0):
        largeur = max(self.largeur, largeur_min)
        hauteur = self.y + self.hauteur_ligne
        return (f'<svg xmlns="{SVG}" width="{largeur}" height="{hauteur}" viewBox="0 0 {largeur} {hauteur}">'
                f'<defs><style type="text/css" id="current-color-scheme">{FEUILLE}</style>{extra_defs}</defs>'
                + "".join(self.elements) + extra + "</svg>\n")


def ombres_de_breeze(fichier):
    """Définitions et ombres (shadow-*) d'un SVG de Breeze, avec leurs
    coordonnées, et la taille de son document : la planche d'Ankh se range
    en dessous. Les ombres sont au premier niveau du document dans Breeze
    6.7 : un élément imbriqué ferait échouer la construction, plutôt que
    d'être recopié sans la transformation de son parent (Qt l'ignore quand
    il mesure un élément : QSvgRenderer::boundsOnElement)."""
    with gzip.open(fichier) as f:
        racine = ET.parse(f).getroot()
    defs = []
    ombres = []
    imbriquees = []
    for enfant in racine:
        balise = enfant.tag.split("}")[-1]
        if balise == "defs":
            defs.extend(e for e in enfant if e.tag.split("}")[-1] != "style")
        elif enfant.get("id", "").startswith("shadow-"):
            ombres.append(enfant)
    for e in racine.iter():
        if e.get("id", "").startswith("shadow-") and e not in ombres and e.tag.split("}")[-1] not in ("linearGradient", "radialGradient", "stop"):
            if not any(e in list(o.iter()) for o in ombres):
                imbriquees.append(e.get("id"))
    if imbriquees:
        sys.exit(f"style-ankh.py : ombres imbriquées dans {fichier} : {imbriquees}")
    if not ombres:
        sys.exit(f"style-ankh.py : aucune ombre dans {fichier}")
    texte_defs = "".join(ET.tostring(e, encoding="unicode") for e in defs)
    texte_ombres = "".join(ET.tostring(e, encoding="unicode") for e in ombres)
    largeur = math.ceil(float(racine.get("width")))
    hauteur = math.ceil(float(racine.get("height")))
    return texte_defs, texte_ombres, largeur, hauteur


def volet(rayon, opacite, marge, y0):
    """Volet de Windows 11 : fond, contour de 1 px, masque (zone floutée)."""
    planche = Planche(y0)
    c = rayon
    L = H = 2 * c + 4
    # Le fond couvre toute la forme et le contour est posé dessus, comme
    # dans WinUI : le coin garde son rayon même quand le contour se voit à
    # peine sur un fond sombre
    fond = arrondi(0, 0, L, H, c)
    anneau = [arrondi(0, 0, L, H, c), list(reversed(arrondi(1, 1, L - 1, H - 1, c - 1)))]
    planche.cadre("", c, c, c, c, [([fond], "Background", opacite), (anneau, "Text", 0.12)])
    planche.cadre("mask", c, c, c, c, [([arrondi(0, 0, L, H, c)], None, 1)])
    planche.marges("", marge, marge, marge, marge)
    for cote in ("top", "bottom", "left", "right"):
        ox, oy = planche.place(4, 1e-8)
        planche.ajouter(f'<rect id="hint-{cote}-inset" x="{ox}" y="{oy}" width="4" height="1e-08" fill="#00ff00"/>')
    return planche


def barre(opacite):
    """Barre des tâches : translucide, un trait de 1 px en haut, coins de 8
    si elle flotte (collée, Plasma n'en dessine que le bord haut)."""
    planche = Planche()
    c = 8
    L = H = 2 * c + 4
    fond = arrondi(0, 0, L, H, c)
    trait = [decouper(arrondi(0, 0, L, H, c), 0, 0, L, 1)]
    planche.cadre("", c, c, c, c, [([fond], "Background", opacite), (trait, "Text", 0.08)])
    planche.cadre("mask", c, c, c, c, [([fond], None, 1)])
    planche.marges("", 4, 4, 4, 4)
    planche.marges("thick", 8, 8, 8, 8, nom="hint")
    return planche


def taches():
    """Boutons de la barre des tâches (applets/taskmanager de plasma-desktop :
    préfixes normal, focus, minimized, attention, progress, et leurs
    variantes « -hover » au survol ; launcher-hover pour une application
    épinglée non ouverte)."""
    planche = Planche()
    marge = 12   # icônes de 24 dans une barre de 48
    retrait = 4  # carré de 40×40 dans un bouton de 48
    r = 4        # ControlCornerRadius
    trait = 3    # épaisseur du trait sous l'icône

    def cadre(prefixe, fond, classe_fond, longueur_trait, classe_trait, opacite_trait):
        # Bords : le carré arrondi tient dans les coins. Le trait est au
        # milieu du bord bas : sa partie droite s'étire avec le bouton, et
        # ses bouts arrondis, fixes, sont dans les coins, 2 px avant leur
        # bord. Dans un bouton de 48, il fait longueur_trait de bout en bout.
        debord = 2
        cote = (48 - longueur_trait) // 2 + debord if longueur_trait else retrait + r
        haut, bas = retrait + r, retrait + r + 4
        L, H = 2 * cote + 4, haut + bas + 4
        formes = []
        if fond:
            formes.append(([arrondi(retrait, retrait, L - retrait, H - retrait, r)], classe_fond, fond))
        if longueur_trait:
            y1 = H - retrait - 1
            formes.append(([pastille(cote - debord, y1 - trait, L - cote + debord, y1)], classe_trait, opacite_trait))
        planche.cadre(prefixe, cote, haut, cote, bas, formes)
        planche.marges(prefixe, marge, marge, marge, marge)

    survol, actif, actif_survol = 0.06, 0.045, 0.08
    cadre("normal", 0, None, 6, "Text", 0.55)
    cadre("normal-hover", survol, "Text", 6, "Text", 0.55)
    cadre("minimized", 0, None, 6, "Text", 0.55)
    cadre("minimized-hover", survol, "Text", 6, "Text", 0.55)
    cadre("focus", actif, "Text", 16, "Highlight", 1)
    cadre("focus-hover", actif_survol, "Text", 16, "Highlight", 1)
    cadre("attention", 0.25, "NeutralText", 16, "NeutralText", 1)
    cadre("attention-hover", 0.35, "NeutralText", 16, "NeutralText", 1)
    cadre("hover", survol, "Text", 0, None, 0)
    cadre("launcher-hover", survol, "Text", 0, None, 0)
    # Progression : un trait d'accent sous le carré, que Plasma découvre de
    # gauche à droite (TaskProgressOverlay.qml)
    cadre("progress", 0, None, 40 - 2 * r, "Highlight", 1)
    return planche


def ecrire(chemin, texte):
    chemin.parent.mkdir(parents=True, exist_ok=True)
    chemin.write_text(texte, encoding="utf-8")
    # Le SVG doit se lire, et chaque morceau attendu y être
    ET.fromstring(texte)


def main(breeze, sortie):
    # Variantes : translucent/ quand le flou est actif ; solid/ pour les
    # volets qui demandent un fond plein (Dialog::SolidBackground de libplasma)
    for nom, rayon, opacite in (("dialogs/background", 8, 0.95),
                                ("translucent/dialogs/background", 8, 0.85),
                                ("solid/dialogs/background", 8, 1),
                                ("widgets/tooltip", 4, 0.95),
                                ("solid/widgets/tooltip", 4, 1)):
        defs, ombres, largeur, hauteur = ombres_de_breeze(breeze / (nom + ".svgz"))
        planche = volet(rayon, opacite, 4, hauteur + 8)
        ecrire(sortie / (nom + ".svg"), planche.texte(defs, ombres, largeur))
        print(f"Style Plasma d'Ankh : {nom} (coins de {rayon}, fond à {opacite:g}, ombres de Breeze)")
    ecrire(sortie / "widgets/panel-background.svg", barre(0.6).texte())
    # Barre opaque (réglage « opaque » de la barre)
    ecrire(sortie / "solid/widgets/panel-background.svg", barre(1).texte())
    print("Style Plasma d'Ankh : widgets/panel-background (fond à 0,6, opaque dans solid/, trait de 1 px en haut, sans ombre)")
    ecrire(sortie / "widgets/tasks.svg", taches().texte())
    print("Style Plasma d'Ankh : widgets/tasks (carré de 40, trait d'accent de 16×3, tiret de 6×3, icônes de 24)")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]))
