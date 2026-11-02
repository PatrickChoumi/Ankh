#!/usr/bin/python3
"""D-052, lot 10 : contrastes des jeux de couleurs d'Ankh.

Chaque couleur de texte d'un groupe (Window, View, Button, Tooltip, Header,
Complementary) doit se lire sur le fond de son groupe avec un contraste d'au
moins 4,5 : le seuil AA du W3C pour le texte courant (WCAG 2.2, critère 1.4.3 ;
luminance relative et rapport de contraste de ses définitions). Dans le groupe
Selection, le texte principal aussi : c'est celui des menus survolés. Les
autres couleurs de Selection restent celles de Breeze : depuis le lot 8, le
texte d'un élément choisi ne change pas (fond discret).

Usage : contrastes.py FICHIER.colors...
"""

import configparser
import sys

SEUIL = 4.5
GROUPES = ["Colors:Window", "Colors:View", "Colors:Button", "Colors:Tooltip", "Colors:Header", "Colors:Complementary"]
TEXTES = [
    "ForegroundNormal",
    "ForegroundInactive",
    "ForegroundLink",
    "ForegroundVisited",
    "ForegroundNegative",
    "ForegroundNeutral",
    "ForegroundPositive",
]


def luminance(couleur):
    def canal(valeur):
        valeur /= 255
        return valeur / 12.92 if valeur <= 0.04045 else ((valeur + 0.055) / 1.055) ** 2.4

    rouge, vert, bleu = map(canal, couleur)
    return 0.2126 * rouge + 0.7152 * vert + 0.0722 * bleu


def contraste(a, b):
    clair, sombre = sorted((luminance(a), luminance(b)), reverse=True)
    return (clair + 0.05) / (sombre + 0.05)


def couleur(jeu, groupe, cle):
    return tuple(int(x) for x in jeu[groupe][cle].split(",")[:3])


def main():
    if len(sys.argv) < 2:
        print("usage : contrastes.py FICHIER.colors...", file=sys.stderr)
        sys.exit(1)
    fautes = []
    for chemin in sys.argv[1:]:
        jeu = configparser.ConfigParser(strict=False, interpolation=None)
        jeu.optionxform = str
        if not jeu.read(chemin, encoding="utf-8"):
            print(f"Contrastes : {chemin} illisible", file=sys.stderr)
            sys.exit(1)
        paires = [(g, t) for g in GROUPES for t in TEXTES] + [("Colors:Selection", "ForegroundNormal")]
        plus_bas = None
        for groupe, texte in paires:
            if groupe not in jeu or texte not in jeu[groupe]:
                fautes.append(f"{chemin} : {groupe} {texte} absent")
                continue
            rapport = contraste(couleur(jeu, groupe, texte), couleur(jeu, groupe, "BackgroundNormal"))
            if plus_bas is None or rapport < plus_bas[0]:
                plus_bas = (rapport, groupe, texte)
            if rapport < SEUIL:
                fautes.append(f"{chemin} : {groupe} {texte} à {rapport:.2f} (moins de {SEUIL})")
        if plus_bas:
            print(f"Contrastes de {chemin} : {len(paires)} paires, la plus basse {plus_bas[0]:.2f} ({plus_bas[1]} {plus_bas[2]})")
    if fautes:
        print("\n".join(fautes), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
