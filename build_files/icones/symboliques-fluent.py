#!/usr/bin/python3
"""D-052, lot 10i : les icônes symboliques de Fluent suivent les couleurs de KDE.

Fluent peint ses icônes symboliques (dossier symbolic, à la manière de GNOME)
d'une couleur figée : #363636 dans la variante claire, #dedede dans la sombre
(commit c8a244f), sans la feuille <style id="current-color-scheme"> que
KIconLoader remplit avec les couleurs du moment (processSvg, kiconloader.cpp ;
kiconcolors.cpp de KIconThemes 6.31). Plasma ne pouvait donc pas les
recolorer : sur une tuile allumée des paramètres rapides, le pictogramme
restait gris au lieu de prendre la couleur du texte sur l'accent.

Chaque élément peint de la couleur figée (attribut fill ou stroke, ou
propriété du même nom dans style) prend la classe ColorScheme-Text et la
couleur currentColor ; la feuille de l'icône donne à cette classe la couleur
figée, que gardent les programmes qui ne recolorent pas. Les éléments des
classes de GTK (warning, error, success) restent tels quels : GTK les colore
lui-même. Les autres couleurs (pastilles colorées) ne changent pas.

Usage : symboliques-fluent.py COULEUR DOSSIER...
    COULEUR : couleur figée de la variante (#rrggbb) ;
    DOSSIER : dossiers parcourus en profondeur (fichiers réels, pas les liens).
"""

import re
import sys
import xml.dom.minidom
from pathlib import Path

CLASSES_GTK = {"warning", "error", "success"}
BALISE = re.compile(r"<[a-zA-Z][\w:.-]*\b[^>]*>")
RACINE = re.compile(r"<svg\b[^>]*>")
FEUILLE = re.compile(r'<style\b[^>]*\bid="current-color-scheme"[^>]*>.*?</style>', re.DOTALL)


def echec(message):
    print(f"Icônes symboliques de Fluent : {message}", file=sys.stderr)
    sys.exit(1)


def adapter_balise(balise, couleur):
    attribut = re.compile(r'\b(fill|stroke)="' + re.escape(couleur) + '"', re.IGNORECASE)
    propriete = re.compile(r"\b(fill|stroke)\s*:\s*" + re.escape(couleur) + r"\b", re.IGNORECASE)
    if not (attribut.search(balise) or propriete.search(balise)):
        return balise
    classe = re.search(r'\sclass="([^"]*)"', balise)
    if classe and CLASSES_GTK & set(classe.group(1).split()):
        return balise
    balise = attribut.sub(lambda m: f'{m.group(1)}="currentColor"', balise)
    balise = propriete.sub(lambda m: f"{m.group(1)}:currentColor", balise)
    if classe:
        return balise.replace(classe.group(0), ' class="ColorScheme-Text"', 1)
    nom = re.match(r"<[a-zA-Z][\w:.-]*", balise)
    return balise[: nom.end()] + ' class="ColorScheme-Text"' + balise[nom.end() :]


def adapter(chemin, couleur):
    texte = chemin.read_text(encoding="utf-8")
    if couleur not in texte.lower():
        return False
    avant = texte
    texte = BALISE.sub(lambda m: adapter_balise(m.group(0), couleur), texte)
    if texte == avant:
        return False
    regle = f".ColorScheme-Text{{color:{couleur};}}"
    feuille = FEUILLE.search(texte)
    if feuille is None:
        # Pas de feuille : celle de l'icône, juste après la balise svg
        racine = RACINE.search(texte)
        if racine is None:
            echec(f"{chemin} : pas de balise svg")
        ajout = f'<defs><style id="current-color-scheme" type="text/css">{regle}</style></defs>'
        texte = texte[: racine.end()] + ajout + texte[racine.end() :]
    elif "ColorScheme-Text" not in feuille.group(0):
        # Feuille sans la classe du texte (Fluent mélange les deux façons) :
        # la règle s'y ajoute
        fin = feuille.end() - len("</style>")
        texte = texte[:fin] + regle + texte[fin:]
    try:
        xml.dom.minidom.parseString(texte.encode("utf-8"))
    except Exception as erreur:
        echec(f"{chemin} : SVG invalide après l'adaptation ({erreur})")
    chemin.write_text(texte, encoding="utf-8")
    return True


def restes(chemin, couleur):
    """Éléments encore peints de la couleur figée, hors classes de GTK."""
    texte = chemin.read_text(encoding="utf-8")
    return [
        b for b in BALISE.findall(texte)
        if couleur in b.lower() and adapter_balise(b, couleur) != b
    ]


def main():
    if len(sys.argv) < 3 or not re.fullmatch(r"#[0-9a-f]{6}", sys.argv[1]):
        echec("usage : symboliques-fluent.py #rrggbb DOSSIER...")
    couleur = sys.argv[1]
    total = 0
    for dossier in map(Path, sys.argv[2:]):
        if not dossier.is_dir() or dossier.is_symlink():
            echec(f"{dossier} : pas un dossier réel")
        fichiers = [c for c in sorted(dossier.rglob("*.svg")) if not c.is_symlink()]
        adaptees = sum(adapter(c, couleur) for c in fichiers)
        for chemin in fichiers:
            reste = restes(chemin, couleur)
            if reste:
                echec(f"{chemin} : couleur figée restée ({reste[0][:80]})")
        print(f"Icônes symboliques de Fluent : {adaptees} sur {len(fichiers)} suivent les couleurs de KDE dans {dossier}")
        total += adaptees
    if total == 0:
        echec(f"aucune icône adaptée : Fluent n'utilise plus {couleur}")


if __name__ == "__main__":
    main()
