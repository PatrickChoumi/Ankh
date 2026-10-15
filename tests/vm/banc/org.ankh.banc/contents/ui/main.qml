// Galerie du banc de l'interface (D-052, lot 0), installée seulement dans le
// compte de la VM de test (tests/vm/banc/banc.sh), puis ouverte par
// « plasmawindowed org.ankh.banc », comme la fenêtre « Options d'Ankh » :
// les contrôles y sont dessinés par le style des applications de KDE en QML
// (org.kde.desktop de qqc2-desktop-style, qui passe par le style Qt).

import QtQuick

import org.kde.plasma.plasmoid

PlasmoidItem {
    Plasmoid.hasConfigurationInterface: false

    preferredRepresentation: fullRepresentation
    fullRepresentation: Galerie {}
}
