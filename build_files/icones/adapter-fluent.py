#!/usr/bin/python3
"""D-052, lot 9 : les dossiers et les icônes d'applications de Fluent suivent
l'accent, comme ceux de Breeze (D-054 : l'accent suit le fond d'écran).

Fluent peint ces icônes d'une seule couleur, celle de sa variante : le bleu
#198ee6 de la variante « standard », toujours en attribut fill="#198ee6"
(src/scalable/places et apps du commit c8a244f). KDE recolore les icônes d'un
thème marqué FollowsColorScheme=true : KIconLoader remplace le contenu de la
feuille <style id="current-color-scheme"> par les couleurs du moment, dont
.ColorScheme-Accent (processSvg, kiconloader.cpp ; kiconcolors.cpp de
KIconThemes 6.31). C'est ainsi que Breeze colore ses dossiers.

Chaque élément peint en #198ee6 prend donc la classe ColorScheme-Accent et la
couleur currentColor ; la feuille de l'icône donne à cette classe le violet
d'Ankh, que voient les applications qui ne recolorent pas (GTK, Flatpak).

Usage : adapter-fluent.py VIOLET DOSSIER...
    VIOLET : couleur par défaut de la feuille (#rrggbb) ;
    DOSSIER : dossiers d'icônes SVG à adapter (fichiers réels, pas des liens).
"""

import re
import sys
import xml.dom.minidom
from pathlib import Path

BLEU_FLUENT = 'fill="#198ee6"'
STYLE_EXISTANT = re.compile(
    r'<style\b[^>]*\bid="current-color-scheme"[^>]*(?:/>|>.*?</style>)', re.DOTALL
)
RACINE = re.compile(r"<svg\b[^>]*>")


def echec(message):
    print(f"Icônes Fluent : {message}", file=sys.stderr)
    sys.exit(1)


def adapter(chemin, violet):
    texte = chemin.read_text(encoding="utf-8")
    if BLEU_FLUENT not in texte:
        return False
    for balise in re.findall(r"<[a-zA-Z]+\b[^>]*" + re.escape(BLEU_FLUENT) + r"[^>]*>", texte):
        if " class=" in balise:
            echec(f"{chemin} : élément déjà classé, à adapter à la main : {balise[:80]}")
    texte = texte.replace(BLEU_FLUENT, 'class="ColorScheme-Accent" fill="currentColor"')
    feuille = (
        '<style id="current-color-scheme" type="text/css">'
        f".ColorScheme-Accent{{color:{violet};}}</style>"
    )
    if STYLE_EXISTANT.search(texte):
        # Deux icônes de Fluent ont déjà une feuille vide (folder-games, folder-bookmark)
        texte = STYLE_EXISTANT.sub(feuille, texte, count=1)
    else:
        racine = RACINE.search(texte)
        if racine is None:
            echec(f"{chemin} : pas de balise svg")
        texte = texte[: racine.end()] + f"<defs>{feuille}</defs>" + texte[racine.end() :]
    if "#198ee6" in texte.lower():
        echec(f"{chemin} : le bleu de Fluent est resté")
    try:
        xml.dom.minidom.parseString(texte.encode("utf-8"))
    except Exception as erreur:
        echec(f"{chemin} : SVG invalide après l'adaptation ({erreur})")
    chemin.write_text(texte, encoding="utf-8")
    return True


def main():
    if len(sys.argv) < 3 or not re.fullmatch(r"#[0-9a-f]{6}", sys.argv[1]):
        echec("usage : adapter-fluent.py #rrggbb DOSSIER...")
    violet = sys.argv[1]
    total = 0
    for dossier in map(Path, sys.argv[2:]):
        if not dossier.is_dir() or dossier.is_symlink():
            echec(f"{dossier} : pas un dossier réel")
        adaptees = sum(
            adapter(chemin, violet)
            for chemin in sorted(dossier.glob("*.svg"))
            if not chemin.is_symlink()
        )
        print(f"Icônes Fluent : {adaptees} icônes à l'accent dans {dossier}")
        total += adaptees
    if total == 0:
        echec("aucune icône adaptée : Fluent a changé sa couleur")


if __name__ == "__main__":
    main()
