#!/usr/bin/python3
"""D-052, lot 9 : la croix de fermeture de Fluent devient une croix simple.

Fluent dessine window-close (16, 22, 24 et 32, dans actions) comme un rond plein
de la couleur « négative » de KDE, rouge, la croix découpée dedans : les
notifications de Plasma et les bandeaux des applications le montraient en
rouge (captures en VM du 2026-11-02). Windows 11, comme Breeze, ferme par une
croix simple, de la couleur du texte. Fluent a cette croix : sa version
symbolique (symbolic/actions/window-close-symbolic.svg, 16 × 16). Elle est
reprise pour chaque taille, de la couleur du texte (.ColorScheme-Text, que
KIconLoader recolore ; la couleur de la variante hors de KDE).

Usage : croix-fluent.py SYMBOLIQUE COULEUR DOSSIER...
    SYMBOLIQUE : window-close-symbolic.svg de Fluent ;
    COULEUR : couleur du texte de la variante (#363636 ou #dedede) ;
    DOSSIER : dossiers <taille>/actions dont le window-close est remplacé.
"""

import re
import sys
import xml.dom.minidom
from pathlib import Path


def echec(message):
    print(f"Croix de Fluent : {message}", file=sys.stderr)
    sys.exit(1)


def main():
    if len(sys.argv) < 4 or not re.fullmatch(r"#[0-9a-f]{6}", sys.argv[2]):
        echec("usage : croix-fluent.py SYMBOLIQUE #rrggbb DOSSIER...")
    symbolique = Path(sys.argv[1]).read_text(encoding="utf-8")
    traces = re.findall(r'<path\b[^>]*\bd="([^"]+)"', symbolique)
    if len(traces) != 1:
        echec(f"{sys.argv[1]} : {len(traces)} tracés au lieu d'un, le dessin a changé")
    couleur = sys.argv[2]
    for dossier in map(Path, sys.argv[3:]):
        cible = dossier / "window-close.svg"
        if not cible.is_file() or cible.is_symlink():
            echec(f"{cible} : absent ou lien")
        if "ColorScheme-NegativeText" not in cible.read_text(encoding="utf-8"):
            echec(f"{cible} : la croix de Fluent n'est plus rouge, à revoir")
        taille = int(dossier.parent.name)
        texte = (
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{taille}" height="{taille}" viewBox="0 0 16 16">'
            '<defs><style id="current-color-scheme" type="text/css">'
            f".ColorScheme-Text{{color:{couleur};}}</style></defs>"
            f'<path class="ColorScheme-Text" fill="currentColor" d="{traces[0]}"/></svg>\n'
        )
        xml.dom.minidom.parseString(texte.encode("utf-8"))
        cible.write_text(texte, encoding="utf-8")
        print(f"Croix de Fluent : {cible} ({taille} px, {couleur})")


if __name__ == "__main__":
    main()
