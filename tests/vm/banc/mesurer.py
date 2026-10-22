#!/usr/bin/env python3
"""Banc de l'interface d'Ankh (D-052, lot 0) : mesures sur les captures de la
VM, puis rapport comparé aux valeurs de Windows 11.

Les captures de mesure sont au format PPM (« screendump » du moniteur de
QEMU), à l'échelle 100 % : un pixel de l'image est un pixel de Plasma. Les
objets mesurés sont posés sur du noir (fond d'écran noir, zone noire de la
galerie) : l'ombre d'une fenêtre, noire elle aussi, ne compte pas.

Usage :
  mesurer.py coin IMAGE X Y L H            rayon du coin haut-gauche d'un
                                           objet (place approchée, en px)
  mesurer.py fermer IMAGE X0 Y0 X1 Y1      taille et couleur de la zone rouge
                                           (bouton Fermer survolé) dans le
                                           rectangle donné
  mesurer.py barre IMAGE X                 barre des tâches, sur la colonne X :
                                           espace en dessous, hauteur, couleur
  mesurer.py tache IMAGE HAUTEUR            bouton de l'application active
                                           dans la barre de HAUTEUR px, en
                                           bas de l'image : longueur et
                                           épaisseur du trait d'accent,
                                           largeur et hauteur du rectangle,
                                           largeur et hauteur du dessin de
                                           l'icône
  mesurer.py couleur IMAGE X Y             couleur d'un pixel
  mesurer.py rapport JETONS MESURES SORTIE compare les mesures (lignes
                                           « id<TAB>valeur ») aux cibles de
                                           JETONS ; écrit le rapport SORTIE
                                           (Markdown) ; échoue si une mesure
                                           obligatoire est hors cible
Python 3.11 ou plus, sans module tiers.
"""
import math
import sys
import tomllib

# Écart de couleur sous lequel un pixel est encore du noir de fond
SEUIL_FOND = 6


def lire_ppm(chemin):
    with open(chemin, "rb") as f:
        donnees = f.read()
    champs = []
    i = 0
    while len(champs) < 4:
        while donnees[i:i + 1].isspace():
            i += 1
        if donnees[i:i + 1] == b"#":
            while donnees[i:i + 1] not in (b"\n", b""):
                i += 1
            continue
        debut = i
        while not donnees[i:i + 1].isspace():
            i += 1
        champs.append(donnees[debut:i])
    if champs[0] != b"P6" or int(champs[3]) != 255:
        sys.exit(f"{chemin} : PPM binaire sur 8 bits attendu")
    return Image(int(champs[1]), int(champs[2]), donnees[i + 1:])


class Image:
    def __init__(self, largeur, hauteur, pixels):
        self.largeur, self.hauteur, self.pixels = largeur, hauteur, pixels

    def px(self, x, y):
        x = min(max(x, 0), self.largeur - 1)
        y = min(max(y, 0), self.hauteur - 1)
        i = 3 * (y * self.largeur + x)
        return tuple(self.pixels[i:i + 3])


def ecart(p, q):
    return max(abs(a - b) for a, b in zip(p, q))


def hexa(p):
    return "#%02x%02x%02x" % p


def bord(profil):
    """Position du bord d'un objet clair sur un fond sombre, le long d'un
    profil (écarts au fond, de l'extérieur vers l'intérieur), à la fraction
    de pixel près : là où l'écart atteint la moitié de celui de l'objet,
    juste après le bord (lissage des contours). None si rien n'est trouvé,
    ou si le profil ne commence pas sur le fond : un autre objet touche
    celui qu'on mesure (run 38709938834 : Dolphin derrière le menu)."""
    for i, v in enumerate(profil):
        if v >= SEUIL_FOND:
            break
    else:
        return None
    if i == 0:
        return None
    interieur = sorted(profil[i + 1:i + 4]) or [profil[i]]
    plateau = max(interieur[len(interieur) // 2], profil[i])
    moitie = plateau / 2
    for j in range(i, len(profil)):
        if profil[j] >= moitie:
            avant = profil[j - 1]
            return j - 1 + (moitie - avant) / (profil[j] - avant) + 0.5
    return None


def rayon_coin(image, x, y, largeur, hauteur):
    """Rayon du coin haut-gauche : l'aire qui manque à l'angle droit est
    r² (1 - π/4) pour un quart de cercle de rayon r."""
    marge = 8
    fond = image.px(x - marge, y + hauteur // 2)
    depart_x, depart_y = x - marge, y - marge
    profondeur = min(24, largeur // 2, hauteur // 2) + marge

    def ligne(yy):
        return [ecart(image.px(xx, yy), fond) for xx in range(depart_x, depart_x + profondeur + marge)]

    def colonne(xx):
        return [ecart(image.px(xx, yy), fond) for yy in range(depart_y, depart_y + profondeur + marge)]

    gauche = bord(ligne(y + hauteur // 2))
    haut = bord(colonne(x + largeur // 2))
    if gauche is None or haut is None:
        return None
    x0, y0 = depart_x + gauche, depart_y + haut
    aire = 0.0
    premiere = round(y0)
    for j in range(min(24, hauteur // 2)):
        b = bord(ligne(premiere + j))
        retrait = (depart_x + b - x0) if b is not None else profondeur
        if retrait < 0.05:
            break
        aire += retrait
    return math.sqrt(aire / (1 - math.pi / 4))


def zone_rouge(image, x0, y0, x1, y1):
    rouges = [(x, y) for y in range(y0, y1) for x in range(x0, x1)
              if (p := image.px(x, y))[0] >= 120 and p[0] - p[1] >= 60 and p[0] - p[2] >= 50]
    if not rouges:
        return None
    xs = [x for x, _ in rouges]
    ys = [y for _, y in rouges]
    # Couleur du fond du bouton : la plus fréquente parmi les pixels rouges
    comptes = {}
    for x, y in rouges:
        p = image.px(x, y)
        comptes[p] = comptes.get(p, 0) + 1
    couleur = max(comptes, key=comptes.get)
    return max(xs) - min(xs) + 1, max(ys) - min(ys) + 1, hexa(couleur)


def barre(image, x):
    noir = (0, 0, 0)
    y = image.hauteur - 1
    espace = 0
    while y >= 0 and ecart(image.px(x, y), noir) < SEUIL_FOND:
        espace += 1
        y -= 1
    bas = y
    while y >= 0 and ecart(image.px(x, y), noir) >= SEUIL_FOND:
        y -= 1
    hauteur = bas - y
    couleur = image.px(x, (bas + y) // 2 + 1) if hauteur else noir
    return espace, hauteur, hexa(couleur)


def tache(image, hauteur_barre):
    """Bouton de l'application active dans la barre des tâches (D-052,
    lot 4) : le trait d'accent sous l'icône, puis le rectangle qui
    l'entoure. Le trait est la plus longue suite de pixels colorés (l'accent
    d'Ankh, figé pendant les mesures) dans le bas de la barre, sous les
    icônes ; le tiret des autres applications est gris. Le rectangle est
    l'ensemble des pixels qui diffèrent de la barre, d'un seul tenant
    autour du trait : son fond est léger (4,5 % de la couleur du texte),
    mais la barre, sur fond noir, est unie."""
    haut = image.hauteur - hauteur_barre
    meilleur = None
    for y in range(haut + 38, image.hauteur):
        x = 0
        while x < image.largeur:
            p = image.px(x, y)
            if max(p) - min(p) >= 40:
                debut = x
                while x < image.largeur and max(q := image.px(x, y)) - min(q) >= 40:
                    x += 1
                if meilleur is None or x - debut > meilleur[2]:
                    meilleur = (debut, y, x - debut)
            x += 1
    if meilleur is None:
        return None
    debut, y_trait, longueur = meilleur
    milieu = debut + longueur // 2
    def colore(y):
        return max(q := image.px(milieu, y)) - min(q) >= 40
    y0 = y1 = y_trait
    while y0 - 1 > haut and colore(y0 - 1):
        y0 -= 1
    while y1 + 1 < image.hauteur and colore(y1 + 1):
        y1 += 1
    epaisseur = y1 - y0 + 1
    # Rectangle : remplissage à partir du trait, sous le trait de 1 px du
    # haut de la barre. La couleur de la barre est la plus fréquente sur sa
    # ligne du milieu.
    comptes = {}
    for x in range(image.largeur):
        q = image.px(x, haut + hauteur_barre // 2)
        comptes[q] = comptes.get(q, 0) + 1
    fond = max(comptes, key=comptes.get)
    vus = {(milieu, y_trait)}
    pile = [(milieu, y_trait)]
    while pile:
        x, y = pile.pop()
        for v in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if v not in vus and 0 <= v[0] < image.largeur and haut < v[1] < image.hauteur \
                    and ecart(image.px(*v), fond) > 4:
                vus.add(v)
                pile.append(v)
    xs = [x for x, _ in vus]
    ys = [y for _, y in vus]
    # Dessin de l'icône : les pixels nets du rectangle, au-dessus du trait
    icone = [(x, y) for x, y in vus if y < y_trait - 1 and ecart(image.px(x, y), fond) > 40]
    ix = [x for x, _ in icone] or [0]
    iy = [y for _, y in icone] or [0]
    return (longueur, epaisseur, max(xs) - min(xs) + 1, max(ys) - min(ys) + 1,
            max(ix) - min(ix) + 1 if icone else 0, max(iy) - min(iy) + 1 if icone else 0)


def nombre(texte):
    try:
        return float(texte)
    except ValueError:
        return None


def couleur_rgb(texte):
    texte = texte.strip().lstrip("#")
    if len(texte) != 6:
        return None
    try:
        return tuple(int(texte[i:i + 2], 16) for i in (0, 2, 4))
    except ValueError:
        return None


def comparer(mesure, valeur):
    """État d'une mesure : (« conforme » | « écart » | « relevé » |
    « non mesuré », écart affiché)."""
    if valeur is None or valeur in ("", "?"):
        return "non mesuré", ""
    if "cible" not in mesure:
        return "relevé", ""
    cible = mesure["cible"]
    tolerance = mesure.get("tolerance", 0)
    if isinstance(cible, (int, float)):
        v = nombre(valeur)
        if v is None:
            return "écart", "non numérique"
        d = v - cible
        texte = ("+" if d > 0 else "") + ("%g" % round(d, 2))
        return ("conforme" if abs(d) <= tolerance else "écart"), texte
    if isinstance(cible, str) and cible.startswith("#"):
        a, b = couleur_rgb(valeur), couleur_rgb(cible)
        if a is None:
            return "écart", "pas une couleur"
        d = ecart(a, b)
        return ("conforme" if d <= tolerance else "écart"), f"{d} sur 255"
    return ("conforme" if str(valeur) == str(cible) else "écart"), ""


def rapport(chemin_jetons, chemin_mesures, sortie):
    with open(chemin_jetons, "rb") as f:
        jetons = tomllib.load(f)
    termines = set(jetons.get("lots_termines", []))
    valeurs = {}
    with open(chemin_mesures, encoding="utf-8") as f:
        for ligne in f:
            if "\t" in ligne:
                cle, valeur = ligne.rstrip("\n").split("\t", 1)
                valeurs[cle] = valeur
    lignes = [
        "# Banc de l'interface d'Ankh (D-052)",
        "",
        "Valeurs relevées dans la VM de test, à l'échelle 100 %, comparées à celles de Windows 11 "
        "(build_files/interface/jetons.toml). Une mesure est obligatoire quand son lot est terminé.",
        "",
        "| Mesure | Ankh | Windows 11 | Écart | Lot | État |",
        "|---|---|---|---|---|---|",
    ]
    comptes = {}
    echecs = []
    connus = set()
    for mesure in jetons["mesure"]:
        connus.add(mesure["id"])
        valeur = valeurs.get(mesure["id"])
        etat, difference = comparer(mesure, valeur)
        # Seules les mesures qui ont une cible peuvent être obligatoires
        obligatoire = mesure["lot"] in termines and "cible" in mesure
        comptes[etat] = comptes.get(etat, 0) + 1
        if obligatoire and etat in ("écart", "non mesuré"):
            echecs.append(f"{mesure['id']} : {valeur or 'absente'} au lieu de {mesure['cible']}")
            etat += " (obligatoire)"
        unite = mesure.get("unite", "")
        lignes.append("| {} (`{}`) | {} | {} | {} | {} | {} |".format(
            mesure["libelle"], mesure["id"],
            f"{valeur} {unite}".strip() if valeur not in (None, "") else "—",
            f"{mesure['cible']} {unite}".strip() if "cible" in mesure else "—",
            difference or "—", mesure["lot"], etat))
    inconnus = sorted(set(valeurs) - connus)
    pluriels = {"conforme": "conformes", "écart": "écarts", "relevé": "relevés", "non mesuré": "non mesurés"}
    lignes += ["", "**Bilan** : " + ", ".join(
        f"{comptes[e]} {e if comptes[e] == 1 else pluriels[e]}" for e in pluriels if e in comptes) + "."]
    if inconnus:
        lignes += ["", "Mesures absentes de jetons.toml : " + ", ".join(f"`{c}`" for c in inconnus) + "."]
    with open(sortie, "w", encoding="utf-8") as f:
        f.write("\n".join(lignes) + "\n")
    print("\n".join(lignes))
    if echecs:
        print("\nMesures obligatoires hors cible :\n- " + "\n- ".join(echecs), file=sys.stderr)
        return 1
    return 0


def main(arguments):
    if not arguments:
        sys.exit(__doc__)
    commande, *reste = arguments
    if commande == "coin" and len(reste) == 5:
        r = rayon_coin(lire_ppm(reste[0]), *map(int, reste[1:]))
        print("?" if r is None else round(r, 2))
    elif commande == "fermer" and len(reste) == 5:
        z = zone_rouge(lire_ppm(reste[0]), *map(int, reste[1:]))
        print("? ? ?" if z is None else "%d %d %s" % z)
    elif commande == "barre" and len(reste) == 2:
        print("%d %d %s" % barre(lire_ppm(reste[0]), int(reste[1])))
    elif commande == "tache" and len(reste) == 2:
        t = tache(lire_ppm(reste[0]), int(reste[1]))
        print("? ? ? ? ? ?" if t is None else "%d %d %d %d %d %d" % t)
    elif commande == "couleur" and len(reste) == 3:
        print(hexa(lire_ppm(reste[0]).px(int(reste[1]), int(reste[2]))))
    elif commande == "rapport" and len(reste) == 3:
        return rapport(*reste)
    else:
        sys.exit(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
