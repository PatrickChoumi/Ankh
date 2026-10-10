"""Dessine le logo, les fonds d'écran, le logo de démarrage et l'image de compte d'Ankh (D-033, D-034, D-037, D-042).

Le logo : un A sans barre, dont la barre devient un curseur de terminal, sur
une touche de clavier graphite. Un seul accent de couleur, violet.

Les images produites sont versionnées dans build_files/files ; ce script sert
seulement à les refaire après une modification du dessin (police DejaVu Sans
Mono nécessaire) :

    uv run --with cairosvg --with pillow --with numpy python build_files/artwork/generer.py
"""

import io
import json
import pathlib
import random

import cairosvg
from PIL import Image, ImageChops, ImageDraw

import fonds

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


def icone_code() -> str:
    """Icône de VS Code dans le menu et la barre (D-042) : la touche graphite
    du logo, avec « </> » en blanc et la barre oblique en violet."""
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
<defs>
<linearGradient id="touche" x1="0" y1="0" x2="0" y2="256" gradientUnits="userSpaceOnUse">
<stop offset="0" stop-color="#232a35"/><stop offset="1" stop-color="#0d1117"/></linearGradient>
</defs>
<rect x="6" y="6" width="244" height="244" rx="56" fill="url(#touche)"/>
<rect x="7.5" y="7.5" width="241" height="241" rx="54.5" fill="none" stroke="#ffffff" stroke-opacity="0.10" stroke-width="3"/>
<path d="M 96 86 L 54 128 L 96 170 M 160 86 L 202 128 L 160 170" fill="none" stroke="{BLANC}"
 stroke-width="20" stroke-linejoin="miter" stroke-miterlimit="10"/>
<path d="M 142 76 L 114 180" fill="none" stroke="{VIOLET}" stroke-width="20"/>
</svg>
"""


def avatar() -> str:
    """Image de compte par défaut (D-042) : la marque sur un disque graphite,
    avec une lueur violette ; rognée en cercle par KDE, sans coin coupé."""
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
<defs>
<radialGradient id="fond" cx="128" cy="96" r="190" gradientUnits="userSpaceOnUse">
<stop offset="0" stop-color="#2a3240"/><stop offset="1" stop-color="#0d1117"/></radialGradient>
<radialGradient id="lueur" cx="128" cy="150" r="80" gradientUnits="userSpaceOnUse">
<stop offset="0" stop-color="{VIOLET}" stop-opacity="0.22"/>
<stop offset="1" stop-color="{VIOLET}" stop-opacity="0"/></radialGradient>
</defs>
<rect width="256" height="256" fill="url(#fond)"/>
<rect width="256" height="256" fill="url(#lueur)"/>
<g transform="translate(128 132) scale(0.78) translate(-128 -128)">{marque(BLANC)}</g>
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


def decrire(paquet: pathlib.Path, nom: str) -> None:
    """Fiche du paquet de fond d'écran, lue par Plasma."""
    fiche = {"KPlugin": {"Authors": [{"Name": "Ankh"}], "Id": paquet.name,
                         "License": "Apache-2.0", "Name": nom}}
    (paquet / "metadata.json").write_text(json.dumps(fiche, indent=4, ensure_ascii=False) + "\n")


def filigrane() -> Image.Image:
    """Logo de l'écran de démarrage : le A et « ankh », en blanc sur fond transparent."""
    image = Image.new("RGBA", (330, 112), (0, 0, 0, 0))
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">{marque(BLANC)}</svg>'
    a = Image.open(io.BytesIO(cairosvg.svg2png(bytestring=svg.encode(), output_width=112, output_height=112)))
    image.alpha_composite(a.convert("RGBA"), (0, 0))
    ImageDraw.Draw(image).text((122, 56), "ankh", fill=BLANC, font=fonds.police_mono(58), anchor="lm")
    return image


def main() -> None:
    icone = RACINE / "icons" / "hicolor" / "scalable" / "apps" / "ankh-logo.svg"
    icone.parent.mkdir(parents=True, exist_ok=True)
    icone.write_text(logo())
    (icone.parent / "ankh-code.svg").write_text(icone_code())

    # Le fond épuré (D-033), en version claire et sombre.
    paquet = RACINE / "wallpapers" / "Ankh"
    for dossier, sombre in (("images", False), ("images_dark", True)):
        cible = paquet / "contents" / dossier / "3840x2160.jpg"
        cible.parent.mkdir(parents=True, exist_ok=True)
        tramer(rendre(fond(sombre), 3840, 2160)).save(cible, quality=92, subsampling=0, optimize=True)
    decrire(paquet, "Ankh Épuré")

    # Les fonds travaillés (D-034), sombres, et la version claire de ceux qui
    # en ont une (D-042).
    for ident, nom, dessin in fonds.COLLECTION:
        paquet = RACINE / "wallpapers" / ident
        variantes = [("images", dessin)]
        if ident in fonds.CLAIRS:
            variantes = [("images_dark", dessin), ("images", fonds.CLAIRS[ident])]
        for dossier, fonction in variantes:
            cible = paquet / "contents" / dossier / "3840x2160.jpg"
            cible.parent.mkdir(parents=True, exist_ok=True)
            toile = fonds.Toile(3840, 2160)
            fonction(toile)
            toile.image().save(cible, quality=90, subsampling=0, optimize=True)
        decrire(paquet, nom)

    # Aperçus des thèmes globaux (D-034) : le fond par défaut, « Ankh Signal ».
    signal = Image.open(RACINE / "wallpapers" / "Ankh-Signal" / "contents" / "images_dark" / "3840x2160.jpg")
    apercus = RACINE / "ankh" / "apercus"
    apercus.mkdir(parents=True, exist_ok=True)
    signal.resize((800, 450), Image.LANCZOS).save(apercus / "preview.png", optimize=True)
    signal.resize((1920, 1080), Image.LANCZOS).save(apercus / "fullscreenpreview.jpg", quality=90)
    verrou = signal.resize((800, 450), Image.LANCZOS).point(lambda v: int(v * 0.6))
    verrou.save(apercus / "lockscreen.png", optimize=True)

    # Fond de l'assistant de premier démarrage (D-037) : « Ankh Signal », aux
    # noms de fichiers que l'assistant cherche (src/qml/LandingComponent.qml de
    # plasma-setup) ; paysage réduit et portrait recadré au centre.
    assistant = RACINE / "ankh" / "assistant"
    assistant.mkdir(parents=True, exist_ok=True)
    signal.convert("RGB").resize((2560, 1440), Image.LANCZOS).save(assistant / "5120x2880.png", optimize=True)
    hauteur = 1920
    largeur = round(signal.width * hauteur / signal.height)
    gauche = (largeur - 1080) // 2
    portrait = signal.convert("RGB").resize((largeur, hauteur), Image.LANCZOS)
    portrait.crop((gauche, 0, gauche + 1080, hauteur)).save(assistant / "1080x1920.png", optimize=True)

    # Image de compte par défaut (D-042), donnée à chaque nouveau compte.
    rendre(avatar(), 512, 512).save(RACINE / "ankh" / "avatar.png", optimize=True)

    cible = RACINE / "ankh" / "plymouth" / "watermark.png"
    cible.parent.mkdir(parents=True, exist_ok=True)
    filigrane().save(cible, optimize=True)


if __name__ == "__main__":
    main()
