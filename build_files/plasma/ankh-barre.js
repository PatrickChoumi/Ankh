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
// Bouton « Vue des tâches », à droite du Démarrer comme dans Windows 11
// (D-052, lot 7b) : il ouvre la vue des tâches d'Ankh, sans raccourci
// (build_files/files/usr/share/plasma/plasmoids/org.ankh.vuetaches)
panel.addWidget("org.ankh.vuetaches")
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
// La liste garde sa taille, au lieu de s'étirer entre les espaceurs : chaque
// bouton fait alors 48 px plus ses marges du style (56), et le trait sous
// l'application active garde ses 16 px. Étirée, la liste rétrécissait les
// boutons selon la place (70 px au lieu de 72 au lot 4, run 39761174583).
// Option « fill » d'applets/taskmanager/main.xml de plasma-desktop.
taches.writeConfig("fill", false)
panel.addWidget("org.kde.plasma.panelspacer")

// Méthode de saisie pour les langues qui en ont besoin, comme dans le modèle.
var langIds = ["as", "bn", "bo", "brx", "doi", "gu", "hi", "ja", "kn", "ko",
               "kok", "ks", "lep", "mai", "ml", "mni", "mr", "ne", "or", "pa",
               "sa", "sat", "sd", "si", "ta", "te", "th", "ur", "vi", "zh_CN",
               "zh_TW"]
if (langIds.indexOf(languageId) != -1) {
    panel.addWidget("org.kde.plasma.kimpanel");
}

// Zone de notification, sans les applets que remplacent les paramètres
// rapides d'Ankh (D-052, lot 6a) : réseau, son, Bluetooth, batterie,
// luminosité et lecteur. Elles sont connues mais pas activées : la zone ne
// les ajoute plus d'elle-même (knownItems et extraItems,
// applets/systemtray/main.xml et plasmoidregistry.cpp de plasma-workspace).
// Les touches de volume et de luminosité restent gérées par les services de
// Plasma (kded de plasma-pa, powerdevil). L'applet des notifications reste
// chargée, car elle affiche les bulles, mais cachée (hiddenItems : rangée
// dans la flèche de la zone) : la cloche et l'historique sont dans l'horloge
// d'Ankh (lot 6b).
var zone = panel.addWidget("org.kde.plasma.systemtray")
zone.currentConfigGroup = ["General"]
var remplacees = ["org.kde.plasma.networkmanagement", "org.kde.plasma.volume", "org.kde.plasma.bluetooth",
                  "org.kde.plasma.battery", "org.kde.plasma.brightness", "org.kde.plasma.mediacontroller"]
var connues = zone.readConfig("knownItems", [])
var actives = zone.readConfig("extraItems", [])
zone.writeConfig("knownItems", connues.concat(remplacees.filter(function (p) { return connues.indexOf(p) < 0 })))
zone.writeConfig("extraItems", actives.filter(function (p) { return remplacees.indexOf(p) < 0 }))
var cachees = zone.readConfig("hiddenItems", [])
if (cachees.indexOf("org.kde.plasma.notifications") < 0) {
    zone.writeConfig("hiddenItems", cachees.concat(["org.kde.plasma.notifications"]))
}
// Paramètres rapides d'Ankh : un seul bouton (réseau, son, batterie), entre
// la zone de notification et l'heure, comme Windows 11. Sans raccourci :
// Ankh garde ceux de KDE (mon choix du 2026-10-23 ; Meta+A y passe d'une
// activité à l'autre)
var reglages = panel.addWidget("org.ankh.reglages")
// Horloge d'Ankh, comme Windows 11 (lot 6b) : l'heure, la date en dessous
// et une cloche ; un clic ouvre les notifications et le calendrier. Sans
// raccourci, comme les paramètres rapides
var horloge = panel.addWidget("org.ankh.horloge")
// Fine bande « Afficher le bureau », comme Windows 11 (D-052, lot 4)
panel.addWidget("org.ankh.bureau")

// Fond d'écran : comme le thème global de Fedora, le module d'images.
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = 'org.kde.image';
}
