#!/usr/bin/python3
"""D-052, lot 8b : le fichier des barres de Dolphin pour l'image d'Ankh.

preparer FRAGMENT FUSION SORTIE
    FUSION est le fichier que KXMLGUI a écrit en fusionnant FRAGMENT
    (barres-ankh.rc, version 1) dans celui de Dolphin (KXmlGuiVersionHandler,
    kxmlguiversionhandler.cpp de KXMLGUI 6.31) : les menus et les états de
    Dolphin, à sa version, avec les barres et les propriétés d'actions
    d'Ankh. Vérifie que la fusion a tout pris, remet les barres dans l'ordre
    du fragment (KXMLGUI les insère à l'envers, une par une après le menu),
    et écrit SORTIE.

verifier FRAGMENT ACTIONS TEXTES
    ACTIONS : la réponse JSON de org.kde.KMainWindow.actions (les actions
    branchées sur un menu ou une barre) de Dolphin lancé avec SORTIE ;
    TEXTES : une ligne « action texte » par témoin, le texte de son bouton
    (iconText) lu par D-Bus. Chaque action des barres doit être branchée, et
    chaque témoin porter le texte d'Ankh : la preuve que Dolphin a lu SORTIE.
"""

import json
import sys
import xml.dom.minidom


def echec(message):
    print(f"Barres de Dolphin : {message}", file=sys.stderr)
    sys.exit(1)


def elements(parent, nom):
    return [n for n in parent.childNodes if n.nodeType == n.ELEMENT_NODE and n.tagName == nom]


def contenu(barre):
    """Les attributs d'une barre et la suite de ses actions et séparateurs."""
    attributs = {k: v for k, v in barre.attributes.items() if k != "alreadyVisited"}
    suite = []
    for n in barre.childNodes:
        if n.nodeType != n.ELEMENT_NODE or n.tagName == "text":
            continue
        suite.append((n.tagName, n.getAttribute("name")))
    return attributs, suite


def proprietes(document):
    resultat = {}
    for bloc in elements(document.documentElement, "ActionProperties"):
        for action in elements(bloc, "Action"):
            resultat[action.getAttribute("name")] = dict(action.attributes.items())
    return resultat


def barres_du_fragment(chemin):
    fragment = xml.dom.minidom.parse(chemin)
    return fragment, elements(fragment.documentElement, "ToolBar")


def preparer(chemin_fragment, chemin_fusion, chemin_sortie):
    fragment, barres = barres_du_fragment(chemin_fragment)
    fusion = xml.dom.minidom.parse(chemin_fusion)
    racine = fusion.documentElement

    version_fragment = int(fragment.documentElement.getAttribute("version"))
    version = racine.getAttribute("version")
    if not version.isdigit() or int(version) <= version_fragment:
        echec(f"version {version!r} après la fusion : le fichier de Dolphin n'a pas été pris")
    if racine.getAttribute("name") != "dolphin" or not elements(racine, "MenuBar"):
        echec("pas de menus de Dolphin dans la fusion")
    # Écrit par la fusion seule, avant que Dolphin ne construise ses menus et
    # ses barres : sinon, Dolphin l'a réécrit (addHamburgerMenuToToolbar)
    if "alreadyVisited" in fusion.toxml():
        echec("fichier réécrit par Dolphin après la fusion")

    noms = [b.getAttribute("name") for b in barres]
    barres_fusion = {b.getAttribute("name"): b for b in elements(racine, "ToolBar")}
    if sorted(barres_fusion) != sorted(noms):
        echec(f"barres {sorted(barres_fusion)} après la fusion, {sorted(noms)} attendues")
    for barre in barres:
        nom = barre.getAttribute("name")
        if contenu(barres_fusion[nom]) != contenu(barre):
            echec(f"la barre {nom} a changé dans la fusion : {contenu(barres_fusion[nom])}")

    attendues = proprietes(fragment)
    obtenues = proprietes(fusion)
    for nom, attributs in attendues.items():
        if obtenues.get(nom) != attributs:
            echec(f"propriétés de {nom} : {obtenues.get(nom)}, {attributs} attendues")

    # Les barres dans l'ordre du fragment, juste après le menu
    for nom in noms:
        racine.removeChild(barres_fusion[nom])
    apres = elements(racine, "MenuBar")[0].nextSibling
    for nom in noms:
        racine.insertBefore(barres_fusion[nom], apres)
    if [b.getAttribute("name") for b in elements(racine, "ToolBar")] != noms:
        echec("ordre des barres")

    with open(chemin_sortie, "w", encoding="utf-8") as sortie:
        sortie.write(fusion.toxml())
    print(f"Barres de Dolphin : fusion à la version {version} de Dolphin, barres {', '.join(noms)}")


def verifier(chemin_fragment, chemin_actions, chemin_textes):
    fragment, barres = barres_du_fragment(chemin_fragment)
    with open(chemin_actions, encoding="utf-8") as f:
        reponse = json.load(f)
    branchees = set(reponse["data"][0])
    for barre in barres:
        for genre, nom in contenu(barre)[1]:
            if genre == "Action" and nom not in branchees:
                echec(f"l'action {nom} (barre {barre.getAttribute('name')}) n'existe pas ou n'est pas branchée dans Dolphin")

    attendus = {nom: a["iconText"] for nom, a in proprietes(fragment).items() if "iconText" in a}
    lus = {}
    with open(chemin_textes, encoding="utf-8") as f:
        for ligne in f:
            nom, _, texte = ligne.rstrip("\n").partition(" ")
            lus[nom] = json.loads(texte)["data"]
    if not lus:
        echec("aucun témoin lu")
    for nom, texte in lus.items():
        if attendus.get(nom) != texte:
            echec(f"le bouton {nom} dit {texte!r}, {attendus.get(nom)!r} attendu : Dolphin n'a pas lu le fichier d'Ankh")
    print(f"Barres de Dolphin : {len(branchees)} actions branchées, dont toutes celles des barres ; "
          + ", ".join(f"{nom} « {texte} »" for nom, texte in sorted(lus.items())))


if __name__ == "__main__":
    if len(sys.argv) == 5 and sys.argv[1] == "preparer":
        preparer(*sys.argv[2:])
    elif len(sys.argv) == 5 and sys.argv[1] == "verifier":
        verifier(*sys.argv[2:])
    else:
        echec("usage : preparer FRAGMENT FUSION SORTIE | verifier FRAGMENT ACTIONS TEXTES")
