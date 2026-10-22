// Barre d'Ankh : la barre des tâches de Windows 11 (D-052, lot 4), collée en
// bas sur toute la largeur, le menu et les applications au centre, la zone de
// notification et l'horloge à droite. Adapté du modèle de KDE
// (layout-templates/org.kde.plasma.desktop.defaultPanel de
// https://invent.kde.org/plasma/plasma-desktop) ; le sélecteur de bureaux
// virtuels est retiré.
var panel = new Panel

// 48 px, collée au bord de l'écran, comme celle de Windows 11 (mon choix du
// 2026-10-14) ; elle remplace la barre flottante de D-037 et D-039.
panel.height = 48
panel.floating = false
// Toujours translucide et floutée (D-042), même quand une fenêtre est
// agrandie : la barre est une couche de navigation qui flotte au-dessus du
// contenu, comme le Dock de macOS (Liquid Glass) ou la barre des tâches de
// Windows 11. Par défaut, Plasma la rend opaque dans ce cas (« adaptive »,
// PanelView::OpacityMode de shell/panelview.h, plasma-workspace).
panel.opacity = "translucent"

// Deux espaceurs extensibles centrent sur la barre ce qui est entre eux
// (optimalSize de applets/panelspacer/main.qml, plasma-workspace).
panel.addWidget("org.kde.plasma.panelspacer")
// Démarrer d'Ankh (D-052, lot 5), à la place de Kickoff : le Démarrer de
// Windows 11, dérivé de Kickoff (build_files/files/usr/share/plasma/plasmoids/org.ankh.demarrer)
panel.addWidget("org.ankh.demarrer")
// Applications épinglées (D-042) : fichiers, navigateur, VS Code, Steam,
// terminal, Discover et réglages. Les deux premières sont les applications
// par défaut du système (preferred://, applets/taskmanager/main.xml de
// plasma-desktop). VS Code et Steam ne sont épinglés que si les options Dev
// et Gaming sont choisies (D-046, D-050) : leur entrée n'existe pas sinon
// (applicationExists, shell/scripting/scriptengine_v1.cpp de plasma-workspace).
var epinglees = ["preferred://filemanager", "preferred://browser"]
if (applicationExists("ankh-vscode.desktop")) {
    epinglees.push("applications:ankh-vscode.desktop")
}
if (applicationExists("com.valvesoftware.Steam.desktop")) {
    epinglees.push("applications:com.valvesoftware.Steam.desktop")
}
epinglees.push("applications:org.kde.konsole.desktop", "applications:org.kde.discover.desktop",
               "applications:systemsettings.desktop")
var taches = panel.addWidget("org.kde.plasma.icontasks")
taches.currentConfigGroup = ["General"]
taches.writeConfig("launchers", epinglees)
panel.addWidget("org.kde.plasma.panelspacer")

// Méthode de saisie pour les langues qui en ont besoin, comme dans le modèle.
var langIds = ["as", "bn", "bo", "brx", "doi", "gu", "hi", "ja", "kn", "ko",
               "kok", "ks", "lep", "mai", "ml", "mni", "mr", "ne", "or", "pa",
               "sa", "sat", "sd", "si", "ta", "te", "th", "ur", "vi", "zh_CN",
               "zh_TW"]
if (langIds.indexOf(languageId) != -1) {
    panel.addWidget("org.kde.plasma.kimpanel");
}

panel.addWidget("org.kde.plasma.systemtray")
// Heure, et date en dessous, comme Windows 11 (dateDisplayFormat : 2,
// « BelowTime », applets/digital-clock/main.xml de plasma-workspace)
var horloge = panel.addWidget("org.kde.plasma.digitalclock")
horloge.currentConfigGroup = ["Appearance"]
horloge.writeConfig("dateDisplayFormat", 2)
// Fine bande « Afficher le bureau », comme Windows 11 (D-052, lot 4)
panel.addWidget("org.ankh.bureau")

// Fond d'écran : comme le thème global de Fedora, le module d'images.
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = 'org.kde.image';
}
