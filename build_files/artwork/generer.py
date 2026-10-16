"""Dessine le logo, les fonds d'écran, l'écran de démarrage, l'écran de connexion et l'image de compte d'Ankh (D-033, D-034, D-037, D-042, D-043).

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
from PIL import Image, ImageChops, ImageFilter

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
    """Fiche du paquet de fond d'écran, lue par Plasma.

    D-054 : la couleur d'accent suit le fond d'écran. Chaque fond d'Ankh
    désigne le violet d'Ankh, celui des jeux de couleurs clair et sombre
    (X-KDE-PlasmaImageWallpaper-AccentColor, lu par
    wallpapers/image/plugin/utils/mediaproxy.cpp de plasma-workspace :
    « Dark » avec un jeu de couleurs sombre, « Light » sinon)."""
    fiche = {"KPlugin": {"Authors": [{"Name": "Ankh"}], "Id": paquet.name,
                         "License": "Apache-2.0", "Name": nom},
             "X-KDE-PlasmaImageWallpaper-AccentColor": {"Light": VIOLET_FONCE, "Dark": VIOLET}}
    (paquet / "metadata.json").write_text(json.dumps(fiche, indent=4, ensure_ascii=False) + "\n")


def plymouth(dossier: pathlib.Path) -> None:
    """Images de l'écran de démarrage d'Ankh (D-043), thème Plymouth « ankh » :
    le logo (même taille que sur l'écran de chargement de la session), et le
    champ du mot de passe du disque, sa puce et son cadenas."""
    dossier.mkdir(parents=True, exist_ok=True)
    rendre_rgba = lambda svg, l, h: Image.open(io.BytesIO(cairosvg.svg2png(
        bytestring=svg.encode(), output_width=l, output_height=h))).convert("RGBA")
    rendre_rgba(logo(), 144, 144).save(dossier / "watermark.png", optimize=True)
    # Champ en pilule, comme celui de l'écran de connexion
    champ = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 40">'
             '<rect x="1" y="1" width="298" height="38" rx="19" fill="#161b22" '
             f'stroke="{VIOLET}" stroke-width="2"/></svg>')
    rendre_rgba(champ, 300, 40).save(dossier / "entry.png", optimize=True)
    # Puce : Plymouth dessine la puce n à x + n × L + L / 2 du bord du champ,
    # L étant la largeur de l'image (src/libply-splash-graphics/ply-entry.c de
    # https://gitlab.freedesktop.org/plymouth/plymouth). Une image de 15 px,
    # avec le point à droite, met le premier point à 18,5 px du bord : hors de
    # l'arrondi de la pilule, comme le texte du champ de l'écran de connexion.
    puce = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 15 15">'
            f'<circle cx="11" cy="7.5" r="3.5" fill="{BLANC}"/></svg>')
    rendre_rgba(puce, 15, 15).save(dossier / "bullet.png", optimize=True)
    cadenas = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 24">'
               f'<path d="M5 10 V7 a5 5 0 0 1 10 0 V10" fill="none" stroke="{BLANC}" stroke-width="2.2"/>'
               f'<rect x="2" y="10" width="16" height="12" rx="3" fill="{BLANC}"/></svg>')
    rendre_rgba(cadenas, 20, 24).save(dossier / "lock.png", optimize=True)


def main() -> None:
    icone = RACINE / "icons" / "hicolor" / "scalable" / "apps" / "ankh-logo.svg"
    icone.parent.mkdir(parents=True, exist_ok=True)
    icone.write_text(logo())

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

    # Fond de l'écran de connexion (D-043) : « Ankh Signal » flouté et un peu
    # assombri, comme le fond de l'écran de connexion de Windows 11. Préparé
    # ici pour que l'écran de connexion n'ait aucun effet à calculer.
    connexion = signal.convert("RGB").resize((2560, 1440), Image.LANCZOS).filter(ImageFilter.GaussianBlur(36))
    connexion = connexion.point(lambda v: int(v * 0.85))
    cible = RACINE / "sddm" / "themes" / "ankh" / "fond.jpg"
    cible.parent.mkdir(parents=True, exist_ok=True)
    tramer(connexion).save(cible, quality=90, subsampling=0, optimize=True)

    # Image de compte par défaut (D-042), donnée à chaque nouveau compte.
    rendre(avatar(), 512, 512).save(RACINE / "ankh" / "avatar.png", optimize=True)

    plymouth(RACINE / "plymouth" / "themes" / "ankh")


if __name__ == "__main__":
    main()
