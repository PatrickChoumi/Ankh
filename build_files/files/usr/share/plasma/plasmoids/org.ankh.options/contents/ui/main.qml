// Fenêtre « Options d'Ankh » (D-046), ouverte depuis la Configuration du
// système (catégorie Système) ou le menu par « plasmawindowed
// org.ankh.options » : plasmawindowed (plasma-windowed de
// https://invent.kde.org/plasma/plasma-workspace) montre un widget de Plasma
// dans une fenêtre ordinaire, à la taille minimale de son contenu. Ce widget
// est caché de la liste des widgets (NoDisplay, metadata.json).

import QtQuick

import org.kde.plasma.plasmoid

PlasmoidItem {
    // Rien à configurer : pas de « Configurer… » au clic droit
    Plasmoid.hasConfigurationInterface: false

    preferredRepresentation: fullRepresentation
    fullRepresentation: Fenetre {}
}
