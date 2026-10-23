#!/usr/bin/env python3
"""Adapte l'écran de déconnexion de KDE au dessin d'Ankh (D-052, lot 7c).

L'écran de déconnexion (ksmserver-logout-greeter de plasma-workspace 6.7,
logout-greeter/shutdowndlg.cpp) charge contents/logout/Logout.qml du thème
global choisi. Il prend le dessin de l'écran de connexion d'Ankh (D-043),
comme l'écran de verrouillage (mon choix du 2026-10-23, « Comme la connexion
d'Ankh ») : le voile graphite d'Ankh au lieu du noir de KDE, plus léger,
car le programme demande à KWin de flouter ce qui est derrière lui
(KWindowEffects::enableBlurBehind) ; et les boutons ronds translucides de la
connexion (LogoutButton.qml d'Ankh, posé à côté par build.sh).

Seul le dessin change : les actions (veille, redémarrer, éteindre, se
déconnecter, annuler), les mises à jour à installer avant de redémarrer ou
d'éteindre, le compte à rebours et le clavier restent ceux de KDE.

Le texte remplacé est vérifié : si une nouvelle version de Plasma l'a
changé, la construction échoue.

Usage : adapter-deconnexion.py <fichier Logout.qml>
"""

import pathlib
import sys

FICHIER = pathlib.Path(sys.argv[1])


def remplacer(texte: str, avant: str, apres: str) -> str:
    nombre = texte.count(avant)
    if nombre != 1:
        sys.exit(f"adapter-deconnexion.py : {FICHIER} contient {nombre} fois, au lieu d'une, le texte :\n{avant}")
    return texte.replace(avant, apres)


texte = FICHIER.read_text(encoding="utf-8")
texte = remplacer(
    texte,
    "        // Intentionally hardcoded because any other color looks terrible here.\n"
    "        // Any bug reports about illegible text or icons should be considered\n"
    "        // a color scheme error and sent back to the user or their distro.\n"
    '        color: "black"\n'
    "        opacity: 0.85\n",
    "        // Ankh : le voile graphite de l'écran de connexion d'Ankh (D-043,\n"
    "        // #0d1117), sur ce que KWin floute derrière l'écran (D-052, lot 7c)\n"
    '        color: "#0d1117"\n'
    "        opacity: 0.70\n",
)
FICHIER.write_text(texte, encoding="utf-8")
