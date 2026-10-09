"""Règle « À propos de ce système » sur Ankh (D-034).

KDE lit le logo, la variante et le site de cette page dans kcm-about-distrorc,
avant os-release (kcms/about-distro/src/main.cpp de
https://invent.kde.org/plasma/kinfocenter). Ce script règle ces trois clés du
groupe [General] du fichier donné, en gardant les autres lignes, et crée le
fichier s'il n'existe pas.

    python3 regler-a-propos.py /etc/xdg/kcm-about-distrorc
"""

import os
import sys

VALEURS = {
    "LogoPath": "/usr/share/icons/hicolor/scalable/apps/ankh-logo.svg",
    "Variant": "",
    "Website": "https://github.com/PatrickChoumi/Ankh",
}


def regler(lignes: list[str]) -> list[str]:
    sortie: list[str] = []
    dans_general = False
    vues: set[str] = set()

    def completer() -> None:
        sortie.extend(f"{cle}={valeur}" for cle, valeur in VALEURS.items() if cle not in vues)

    for ligne in lignes:
        if ligne.startswith("["):
            if dans_general:
                completer()
            dans_general = ligne.strip() == "[General]"
            vues = set()
        elif dans_general and ligne.split("=", 1)[0].strip() in VALEURS:
            cle = ligne.split("=", 1)[0].strip()
            print(f"Avant : {ligne}")
            ligne = f"{cle}={VALEURS[cle]}"
            vues.add(cle)
        sortie.append(ligne)
    if dans_general:
        completer()
    if "[General]" not in (ligne.strip() for ligne in sortie):
        sortie.append("[General]")
        vues = set()
        completer()
    return sortie


def main() -> None:
    chemin = sys.argv[1]
    lignes: list[str] = []
    if os.path.exists(chemin):
        with open(chemin, encoding="utf-8") as f:
            lignes = f.read().splitlines()
    with open(chemin, "w", encoding="utf-8") as f:
        f.write("\n".join(regler(lignes)) + "\n")
    print(f"{chemin} réglé")


if __name__ == "__main__":
    main()
