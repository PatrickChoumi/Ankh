// Barre d'Ankh (D-039) : flottante en bas, le menu et les applications au
// centre comme sous Windows 11, la zone de notification et l'horloge à droite.
// Adapté du modèle de KDE (layout-templates/org.kde.plasma.desktop.defaultPanel
// de https://invent.kde.org/plasma/plasma-desktop) ; le sélecteur de bureaux
// virtuels est retiré.
var panel = new Panel
var panelScreen = panel.screen

// Un peu plus haute que celle de KDE (2,5 unités), arrondie au nombre pair
// supérieur comme dans le modèle.
panel.height = 2 * Math.ceil(gridUnit * 2.75 / 2)
panel.floating = true

// Barre limitée à la largeur d'un écran 21:9, comme dans le modèle.
const maximumAspectRatio = 21/9;
if (panel.formFactor === "horizontal") {
    const geo = screenGeometry(panelScreen);
    const maximumWidth = Math.ceil(geo.height * maximumAspectRatio);

    if (geo.width > maximumWidth) {
        panel.alignment = "center";
        panel.minimumLength = maximumWidth;
        panel.maximumLength = maximumWidth;
    }
}

// Deux espaceurs extensibles centrent sur la barre ce qui est entre eux
// (optimalSize de applets/panelspacer/main.qml, plasma-workspace).
panel.addWidget("org.kde.plasma.panelspacer")
panel.addWidget("org.kde.plasma.kickoff")
panel.addWidget("org.kde.plasma.icontasks")
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
panel.addWidget("org.kde.plasma.digitalclock")
panel.addWidget("org.kde.plasma.showdesktop")

// Fond d'écran : comme le thème global de Fedora, le module d'images.
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = 'org.kde.image';
}
