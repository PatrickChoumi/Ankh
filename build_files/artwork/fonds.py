"""Fonds d'écran « travaillés » d'Ankh (D-034), dessinés autour du logo.

Appelé par generer.py. Chaque fond est sombre, graphite et violet ; « Ankh
Signal » a aussi une version claire (D-042).
"""

import io
import math
import random
import subprocess

import cairosvg
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

BLANC = "#e6edf3"
VIOLET = "#a78bfa"
VW, VH = 3840, 2160  # coordonnées de dessin, quelle que soit la taille rendue


def police_mono(taille):
    chemin = subprocess.run(["fc-match", "-f", "%{file}", "DejaVu Sans Mono"],
                            check=True, capture_output=True, text=True).stdout
    return ImageFont.truetype(chemin, taille)


def hexrgb(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=np.float32) / 255


def marque(lettre=BLANC, accent=VIOLET):
    return (
        f'<path d="M 78 194 L 128 62 L 178 194" fill="none" stroke="{lettre}" '
        f'stroke-width="22" stroke-linejoin="miter" stroke-miterlimit="10"/>'
        f'<rect x="111" y="150" width="34" height="17" fill="{accent}"/>'
    )


def placer(cx, cy, k, **kw):
    return f'<g transform="translate({cx} {cy}) scale({k}) translate(-128 -128)">{marque(**kw)}</g>'


class Toile:
    def __init__(self, w, h):
        self.w, self.h, self.s = w, h, w / VW
        self.img = np.zeros((h, w, 3), dtype=np.float32)

    def svg(self, corps, defs=""):
        svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {VW} {VH}" '
               f'width="{self.w}" height="{self.h}"><defs>{defs}</defs>{corps}</svg>')
        png = cairosvg.svg2png(bytestring=svg.encode(), output_width=self.w, output_height=self.h)
        return np.asarray(Image.open(io.BytesIO(png)).convert("RGBA"), dtype=np.float32) / 255

    def dessus(self, rgba, k=1.0):
        a = rgba[..., 3:4] * k
        self.img = self.img * (1 - a) + rgba[..., :3] * a

    def lueur(self, rgba, rayon, force):
        pre = (rgba[..., :3] * rgba[..., 3:4] * 255).clip(0, 255).astype(np.uint8)
        flou = Image.fromarray(pre).filter(ImageFilter.GaussianBlur(rayon * self.s))
        self.img = np.clip(self.img + np.asarray(flou, dtype=np.float32) / 255 * force, 0, 1)

    def fond(self, haut="#0b0e13", bas="#151b24", vignette=0.45):
        y, x = np.mgrid[0:self.h, 0:self.w].astype(np.float32)
        t = (x / self.w * 0.6 + y / self.h * 0.4)[..., None]
        self.img = hexrgb(haut) * (1 - t) + hexrgb(bas) * t
        d = np.sqrt(((x / self.w - 0.5) * 1.5) ** 2 + (y / self.h - 0.5) ** 2)
        self.img *= (1 - vignette * np.clip(d - 0.25, 0, 1))[..., None]

    def halo(self, cx, cy, r, couleur, force):
        y, x = np.mgrid[0:self.h, 0:self.w].astype(np.float32)
        d2 = ((x - cx * self.s) ** 2 + (y - cy * self.s) ** 2) / (r * self.s) ** 2
        self.img = np.clip(self.img + np.exp(-d2)[..., None] * hexrgb(couleur) * force, 0, 1)

    def assombrir(self, cx, cy, r, force):
        y, x = np.mgrid[0:self.h, 0:self.w].astype(np.float32)
        d2 = ((x - cx * self.s) ** 2 + (y - cy * self.s) ** 2) / (r * self.s) ** 2
        self.img *= (1 - force * np.exp(-d2))[..., None]

    def voile(self, rgba, rayon, force):
        """Lueur pour un fond clair : le calque flouté est posé par-dessus
        (une lueur additive disparaîtrait dans le clair)."""
        flou = Image.fromarray((rgba * 255).clip(0, 255).astype(np.uint8), "RGBA")
        flou = flou.filter(ImageFilter.GaussianBlur(rayon * self.s))
        self.dessus(np.asarray(flou, dtype=np.float32) / 255, force)

    def teinter(self, cx, cy, r, couleur, force):
        """Halo pour un fond clair : mélange vers une couleur, sans éclaircir."""
        y, x = np.mgrid[0:self.h, 0:self.w].astype(np.float32)
        d2 = ((x - cx * self.s) ** 2 + (y - cy * self.s) ** 2) / (r * self.s) ** 2
        w = (np.exp(-d2) * force)[..., None]
        self.img = self.img * (1 - w) + hexrgb(couleur) * w

    def image(self):
        rng = np.random.default_rng(33)
        bruit = rng.integers(-1, 2, size=(self.h, self.w, 1)).astype(np.float32) / 255
        return Image.fromarray(((self.img + bruit).clip(0, 1) * 255).astype(np.uint8))


def melange(a, b, t):
    c = hexrgb(a) * (1 - t) + hexrgb(b) * t
    return "#%02x%02x%02x" % tuple(int(v * 255) for v in c)


def signal(t: Toile):
    """Rubans de lumière qui ondulent, façon fibre optique."""
    t.fond()
    lignes = []
    n = 80
    for k in range(n):
        u = k / (n - 1)
        pts = []
        for x in range(-40, VW + 41, 20):
            p = x / VW * 2 * math.pi
            y = (1560 - u * 520 + 230 * math.sin(p * 1.05 + 0.6 + u * 1.4)
                 + 120 * math.sin(p * 2.2 + 1.9 + u * 3.1) + 40 * math.sin(p * 5.0 + u * 7))
            pts.append(f"{x},{y:.1f}")
        coul = melange("#7c3aed", "#22d3ee", u) if u > 0.5 else melange("#c084fc", "#7c3aed", u * 2)
        op = 0.08 + 0.55 * (1 - abs(u - 0.5) * 2) ** 3
        lignes.append(f'<polyline points="{" ".join(pts)}" fill="none" stroke="{coul}" '
                      f'stroke-opacity="{op:.3f}" stroke-width="2.4"/>')
    calque = t.svg("".join(lignes))
    t.lueur(calque, 26, 1.3)
    t.dessus(calque)
    t.halo(2760, 760, 520, "#7c3aed", 0.20)
    m = t.svg(placer(2760, 760, 2.6))
    t.lueur(m, 40, 0.5)
    t.dessus(m)


def signal_clair(t: Toile):
    """Version claire d'« Ankh Signal » (D-042), pour le thème « Ankh Clair » :
    mêmes rubans, en violet et cyan foncés sur un gris très clair."""
    t.fond(haut="#f5f6f8", bas="#e3e7ee", vignette=0.10)
    lignes = []
    n = 80
    for k in range(n):
        u = k / (n - 1)
        pts = []
        for x in range(-40, VW + 41, 20):
            p = x / VW * 2 * math.pi
            y = (1560 - u * 520 + 230 * math.sin(p * 1.05 + 0.6 + u * 1.4)
                 + 120 * math.sin(p * 2.2 + 1.9 + u * 3.1) + 40 * math.sin(p * 5.0 + u * 7))
            pts.append(f"{x},{y:.1f}")
        coul = melange("#6d28d9", "#0e7490", u) if u > 0.5 else melange("#9333ea", "#6d28d9", u * 2)
        op = 0.10 + 0.55 * (1 - abs(u - 0.5) * 2) ** 3
        lignes.append(f'<polyline points="{" ".join(pts)}" fill="none" stroke="{coul}" '
                      f'stroke-opacity="{op:.3f}" stroke-width="2.4"/>')
    calque = t.svg("".join(lignes))
    t.voile(calque, 26, 0.6)
    t.dessus(calque)
    t.teinter(2760, 760, 520, "#ddd6fe", 0.55)
    m = t.svg(placer(2760, 760, 2.6, lettre="#1b212b", accent="#7c3aed"))
    t.voile(m, 40, 0.25)
    t.dessus(m)


def circuit(t: Toile):
    """Pistes de circuit imprimé qui partent du logo."""
    t.fond()
    rng = random.Random(7)
    cx, cy = 1920, 1060
    dirs = [(1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1)]
    traces, noeuds = [], []
    for i in range(110):
        a = i / 110 * 2 * math.pi + rng.uniform(-0.02, 0.02)
        x, y = cx + 470 * math.cos(a), cy + 470 * math.sin(a)
        d = round(a / (math.pi / 4)) % 8
        pts = [(x, y)]
        for _ in range(rng.randint(3, 7)):
            dx, dy = dirs[d]
            n = math.hypot(dx, dy)
            long = rng.uniform(90, 330)
            x, y = x + dx / n * long, y + dy / n * long
            pts.append((x, y))
            d = (d + rng.choice((-1, 0, 0, 1))) % 8
            if not (-50 < x < VW + 50 and -50 < y < VH + 50):
                break
        op = rng.uniform(0.18, 0.55)
        traces.append(f'<polyline points="{" ".join(f"{px:.0f},{py:.0f}" for px, py in pts)}" '
                      f'fill="none" stroke="{VIOLET}" stroke-opacity="{op:.2f}" stroke-width="3.2" '
                      f'stroke-linejoin="round"/>')
        ex, ey = pts[-1]
        noeuds.append(f'<circle cx="{ex:.0f}" cy="{ey:.0f}" r="9" fill="#0d1117" stroke="{VIOLET}" '
                      f'stroke-opacity="{min(1, op + 0.3):.2f}" stroke-width="3"/>')
    anneau = (f'<circle cx="{cx}" cy="{cy}" r="470" fill="none" stroke="{VIOLET}" stroke-opacity="0.35" stroke-width="4"/>'
              f'<circle cx="{cx}" cy="{cy}" r="440" fill="#0d1117" fill-opacity="0.9"/>')
    calque = t.svg("".join(traces) + "".join(noeuds) + anneau)
    t.lueur(calque, 14, 1.4)
    t.dessus(calque)
    t.halo(cx, cy, 380, "#7c3aed", 0.18)
    m = t.svg(placer(cx, cy, 2.4))
    t.lueur(m, 30, 0.45)
    t.dessus(m)


def topographie(t: Toile):
    """Courbes de niveau autour du logo, comme une carte."""
    t.fond()
    rng = np.random.default_rng(5)
    champ = np.zeros((t.h, t.w), dtype=np.float32)
    for (gx, gy), poids in (((7, 4), 1.0), ((14, 8), 0.45), ((28, 16), 0.18)):
        petit = Image.fromarray(rng.random((gy, gx)).astype(np.float32), mode="F")
        champ += np.asarray(petit.resize((t.w, t.h), Image.BICUBIC)) * poids
    y, x = np.mgrid[0:t.h, 0:t.w].astype(np.float32)
    cx, cy = 2560 * t.s, 1080 * t.s
    d = np.sqrt((x - cx) ** 2 + (y - cy) ** 2) / (900 * t.s)
    champ += 1.4 * np.exp(-d ** 2)
    champ = (champ - champ.min()) / (champ.max() - champ.min())
    niveaux = np.floor(champ * 46).astype(np.int32)
    bord = np.zeros_like(champ)
    bord[:, 1:] += niveaux[:, 1:] != niveaux[:, :-1]
    bord[1:, :] += niveaux[1:, :] != niveaux[:-1, :]
    bord = (bord > 0).astype(np.float32)
    if t.s > 0.75:
        epais = Image.fromarray((bord * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(3))
        bord = np.asarray(epais, dtype=np.float32) / 255
    fort = ((niveaux % 5) == 0).astype(np.float32)
    opac = bord * (0.16 + 0.34 * fort) * (0.45 + 0.55 * np.exp(-(d / 1.6) ** 2))
    calque = np.zeros((t.h, t.w, 4), dtype=np.float32)
    calque[..., :3] = hexrgb(VIOLET)
    calque[..., 3] = opac
    t.lueur(calque, 10, 0.9)
    t.dessus(calque)
    t.assombrir(2560, 1080, 330, 0.85)
    m = t.svg(placer(2560, 1080, 2.2))
    t.lueur(m, 30, 0.5)
    t.dessus(m)


def glitch(t: Toile):
    """Le logo en grand, décalé comme un signal vidéo abîmé."""
    t.fond(vignette=0.55)
    cx, cy, k = 1920, 1080, 4.2
    blanc = t.svg(placer(cx, cy, k))
    cyan = t.svg(placer(cx - 16, cy, k, lettre="#22d3ee", accent="#22d3ee"))
    rose = t.svg(placer(cx + 16, cy, k, lettre="#c084fc", accent="#c084fc"))
    for c in (cyan, rose):
        t.img = np.clip(t.img + c[..., :3] * c[..., 3:4] * 0.55, 0, 1)
    t.lueur(blanc, 40, 0.35)
    t.dessus(blanc)
    rng = random.Random(11)
    for _ in range(7):
        y0 = int(rng.uniform(600, 1560) * t.s)
        hgt = max(1, int(rng.uniform(5, 34) * t.s))
        dx = int(rng.choice((-1, 1)) * rng.uniform(14, 70) * t.s)
        t.img[y0:y0 + hgt] = np.roll(t.img[y0:y0 + hgt], dx, axis=1)
    blocs = []
    for _ in range(40):
        bx, by = rng.uniform(900, 2950), rng.uniform(500, 1700)
        coul = rng.choice((VIOLET, "#22d3ee", BLANC))
        blocs.append(f'<rect x="{bx:.0f}" y="{by:.0f}" width="{rng.uniform(20, 220):.0f}" height="{rng.uniform(4, 22):.0f}" '
                     f'fill="{coul}" fill-opacity="{rng.uniform(0.05, 0.35):.2f}"/>')
    t.dessus(t.svg("".join(blocs)))
    lignes = (np.arange(t.h) % max(2, int(6 * t.s)) < max(1, int(2 * t.s))).astype(np.float32)
    t.img *= (1 - 0.18 * lignes)[:, None, None]


def horizon(t: Toile):
    """Grille rétro qui file vers l'horizon, le logo en soleil."""
    t.fond(haut="#07080d", bas="#140d24", vignette=0.3)
    hy, cx = 1300, 1920
    rng = random.Random(3)
    etoiles = "".join(
        f'<circle cx="{rng.uniform(0, VW):.0f}" cy="{rng.uniform(0, hy - 80):.0f}" r="{rng.uniform(1.2, 3.2):.1f}" '
        f'fill="{BLANC}" fill-opacity="{rng.uniform(0.15, 0.7):.2f}"/>' for _ in range(260))
    t.dessus(t.svg(etoiles))
    # Soleil à bandes derrière le logo
    soleil = (f'<linearGradient id="sol" x1="0" y1="{hy - 900}" x2="0" y2="{hy}" gradientUnits="userSpaceOnUse">'
              f'<stop offset="0" stop-color="#c084fc"/><stop offset="1" stop-color="#7c3aed"/></linearGradient>')
    bandes = "".join(f'<rect x="{cx - 700}" y="{hy - 330 + i * 62}" width="1400" height="{8 + i * 4}" fill="#0b0b14"/>' for i in range(6))
    s = t.svg(f'<circle cx="{cx}" cy="{hy - 420}" r="560" fill="url(#sol)" fill-opacity="0.42"/>{bandes}', soleil)
    t.lueur(s, 80, 0.6)
    t.dessus(s)
    # Sol : grille en perspective, qui s'efface vers l'horizon
    t.dessus(t.svg(f'<rect x="0" y="{hy}" width="{VW}" height="{VH - hy}" fill="#05050a"/>'))
    sol = []
    for i in range(-36, 37):
        sol.append(f'<line x1="{cx}" y1="{hy}" x2="{cx + i * 260}" y2="{VH}" stroke="{VIOLET}" stroke-width="3"/>')
    for k in range(1, 26):
        y = hy + (VH - hy) * (k / 25) ** 2.1
        sol.append(f'<line x1="0" y1="{y:.1f}" x2="{VW}" y2="{y:.1f}" stroke="{VIOLET}" stroke-width="3"/>')
    grille = t.svg("".join(sol))
    yy = np.arange(t.h, dtype=np.float32)[:, None]
    grille[..., 3] *= np.clip((yy - hy * t.s) / ((VH - hy) * t.s), 0, 1) ** 0.7
    t.lueur(grille, 16, 0.7)
    t.dessus(grille)
    t.halo(cx, hy, 900, "#7c3aed", 0.22)
    m = t.svg(placer(cx, hy - 420, 2.6))
    t.lueur(m, 30, 0.5)
    t.dessus(m)


def code(t: Toile):
    """Colonnes de code hexadécimal qui tombent, le logo au centre, et l'invite de commande."""
    t.fond(vignette=0.5)
    taille = max(8, int(30 * t.s))
    police = police_mono(taille)
    cw, ch = int(taille * 0.62), int(taille * 1.3)
    cols, lignes = t.w // cw + 1, t.h // ch + 1
    rng = random.Random(21)
    lum = np.zeros((lignes, cols), dtype=np.float32)
    lum += np.array([[rng.uniform(0.02, 0.08) for _ in range(cols)] for _ in range(lignes)])
    for c in rng.sample(range(cols), cols // 3):
        tete = rng.randint(0, lignes)
        long = rng.randint(6, 26)
        for j in range(long):
            r = tete - j
            if 0 <= r < lignes:
                lum[r, c] = max(lum[r, c], 0.75 * (1 - j / long) ** 1.6)
    calque = Image.new("L", (t.w, t.h), 0)
    tete_calque = Image.new("L", (t.w, t.h), 0)
    dr, dt = ImageDraw.Draw(calque), ImageDraw.Draw(tete_calque)
    alphabet = "0123456789abcdef<>/{}[];:=_$#"
    for r in range(lignes):
        for c in range(cols):
            v = lum[r, c]
            if v < 0.02:
                continue
            ch_ = rng.choice(alphabet)
            dr.text((c * cw, r * ch), ch_, fill=int(v * 255), font=police)
            if v > 0.7:
                dt.text((c * cw, r * ch), ch_, fill=255, font=police)
    y, x = np.mgrid[0:t.h, 0:t.w].astype(np.float32)
    cx, cy = 1920 * t.s, 1000 * t.s
    trou = 1 - 0.95 * np.exp(-(((x - cx) / (900 * t.s)) ** 2 + ((y - cy - 120 * t.s) / (720 * t.s)) ** 2))
    a = np.asarray(calque, dtype=np.float32) / 255 * trou
    ca = np.zeros((t.h, t.w, 4), dtype=np.float32)
    ca[..., :3] = hexrgb(VIOLET)
    ca[..., 3] = a
    t.lueur(ca, 6, 0.8)
    t.dessus(ca)
    tt = np.zeros((t.h, t.w, 4), dtype=np.float32)
    tt[..., :3] = hexrgb(BLANC)
    tt[..., 3] = np.asarray(tete_calque, dtype=np.float32) / 255 * trou * 0.8
    t.dessus(tt)
    t.halo(1920, 1000, 420, "#7c3aed", 0.16)
    m = t.svg(placer(1920, 1000, 2.6))
    t.lueur(m, 30, 0.5)
    t.dessus(m)
    # Invite de commande discrète
    p = police_mono(max(8, int(40 * t.s)))
    inv = Image.new("L", (t.w, t.h), 0)
    ImageDraw.Draw(inv).text((1920 * t.s, 1400 * t.s), "ankh ~ $", fill=255, font=p, anchor="mm")
    ia = np.zeros((t.h, t.w, 4), dtype=np.float32)
    ia[..., :3] = hexrgb(BLANC)
    ia[..., 3] = np.asarray(inv, dtype=np.float32) / 255 * 0.7
    t.dessus(ia)


# Versions claires (D-042) : rangées dans contents/images, la version sombre
# passant dans contents/images_dark. Plasma prend l'une ou l'autre selon le
# jeu de couleurs, clair ou sombre (wallpapers/image de plasma-workspace).
CLAIRS = {"Ankh-Signal": signal_clair}

# Collection : (identifiant du paquet, nom affiché, fonction de dessin).
COLLECTION = [
    ("Ankh-Signal", "Ankh Signal", signal),
    ("Ankh-Circuit", "Ankh Circuit", circuit),
    ("Ankh-Topographie", "Ankh Topographie", topographie),
    ("Ankh-Glitch", "Ankh Glitch", glitch),
    ("Ankh-Horizon", "Ankh Horizon", horizon),
    ("Ankh-Code", "Ankh Code", code),
]
