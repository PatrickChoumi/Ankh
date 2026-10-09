"""Dessine le logo et les fonds d'écran d'Ankh (D-033).

Le logo : un A sans barre, dont la barre devient un curseur de terminal, sur
une touche de clavier graphite. Un seul accent de couleur, violet.

Les images produites sont versionnées dans build_files/files ; ce script sert
seulement à les refaire après une modification du dessin :

    uv run --with cairosvg --with pillow python build_files/artwork/generer.py
"""

import io
import pathlib
import random

import cairosvg
from PIL import Image, ImageChops

RACINE = pathlib.Path(__file__).resolve().parents[1] / "files" / "usr" / "share"

BLANC = "#e6edf3"
GRAPHITE = "#1b212b"
VIOLET = "#a78bfa"
VIOLET_FONCE = "#7c3aed"  # sur fond clair, pour garder du contraste


def marque(lettre: str, accent: str = VIOLET) -> str:
    """Le A et son curseur, dans un carré de 256 de côté."""
    return (
        f'<path d="M 78 194 L 128 62 L 178 194" fill="none" stroke="{lettre}" '
        f'stroke-width="22" stroke-linejoin="miter" stroke-miterlimit="10"/>'
        f'<rect x="111" y="150" width="34" height="17" fill="{accent}"/>'
    )


def logo() -> str:
    """Logo : la marque sur une touche de clavier graphite."""
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
<defs>
<linearGradient id="touche" x1="0" y1="0" x2="0" y2="256" gradientUnits="userSpaceOnUse">
<stop offset="0" stop-color="#232a35"/><stop offset="1" stop-color="#0d1117"/></linearGradient>
</defs>
<rect x="6" y="6" width="244" height="244" rx="56" fill="url(#touche)"/>
<rect x="7.5" y="7.5" width="241" height="241" rx="54.5" fill="none" stroke="#ffffff" stroke-opacity="0.10" stroke-width="3"/>
{marque(BLANC)}
</svg>
"""


def fond(sombre: bool) -> str:
    """Fond d'écran 3840x2160 : dégradé, grille de points, marque et lueur violette."""
    if sombre:
        haut, bas, point, lettre, accent = "#0b0e13", "#151b24", "#ffffff", BLANC, VIOLET
    else:
        haut, bas, point, lettre, accent = "#f4f5f7", "#e3e6eb", "#0d1117", GRAPHITE, VIOLET_FONCE
    cx, cy = 2720, 1080
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 3840 2160" width="3840" height="2160">
<defs>
<linearGradient id="fond" x1="0" y1="0" x2="3840" y2="2160" gradientUnits="userSpaceOnUse">
<stop offset="0" stop-color="{haut}"/><stop offset="1" stop-color="{bas}"/></linearGradient>
<pattern id="grille" width="64" height="64" patternUnits="userSpaceOnUse">
<circle cx="32" cy="32" r="2.2" fill="{point}" fill-opacity="0.06"/></pattern>
<radialGradient id="lueur" cx="{cx}" cy="{cy}" r="900" gradientUnits="userSpaceOnUse">
<stop offset="0" stop-color="{accent}" stop-opacity="0.14"/>
<stop offset="1" stop-color="{accent}" stop-opacity="0"/></radialGradient>
</defs>
<rect width="3840" height="2160" fill="url(#fond)"/>
<rect width="3840" height="2160" fill="url(#grille)"/>
<rect width="3840" height="2160" fill="url(#lueur)"/>
<g transform="translate({cx} {cy}) scale(3.6) translate(-128 -128)">{marque(lettre, accent)}</g>
</svg>
"""


def rendre(svg: str, largeur: int, hauteur: int) -> Image.Image:
    png = cairosvg.svg2png(bytestring=svg.encode(), output_width=largeur, output_height=hauteur)
    return Image.open(io.BytesIO(png)).convert("RGB")


def tramer(image: Image.Image) -> Image.Image:
    """Léger bruit (±1 niveau, toujours le même) pour éviter les bandes des dégradés."""
    aleatoire = random.Random(33)
    table = bytes(127 + (i % 3) for i in range(256))
    octets = aleatoire.randbytes(image.width * image.height).translate(table)
    bruit = Image.frombytes("L", image.size, octets).convert("RGB")
    return ImageChops.add(image, bruit, offset=-128)


def main() -> None:
    icone = RACINE / "icons" / "hicolor" / "scalable" / "apps" / "ankh-logo.svg"
    icone.parent.mkdir(parents=True, exist_ok=True)
    icone.write_text(logo())

    paquet = RACINE / "wallpapers" / "Ankh" / "contents"
    for dossier, sombre in (("images", False), ("images_dark", True)):
        cible = paquet / dossier / "3840x2160.jpg"
        cible.parent.mkdir(parents=True, exist_ok=True)
        tramer(rendre(fond(sombre), 3840, 2160)).save(cible, quality=92, subsampling=0, optimize=True)


if __name__ == "__main__":
    main()
