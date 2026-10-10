#!/usr/bin/bash
# D-037 et D-039 : identité visuelle d'Ankh et interface douce. Lancé dans
# l'image par « just test ». Les réglages sont lus comme les lit un compte
# ordinaire (nobody), avec l'ordre des dossiers de réglages de KDE sur
# Fedora : ils doivent lui être lisibles et passer avant ceux de Fedora.
set -euo pipefail

echecs=0
echec() {
    echo "ÉCHEC : $*" >&2
    echecs=$((echecs + 1))
}

# Valeur d'un réglage de KDE pour un compte ordinaire : kreadconfig6 [options].
reglage() {
    runuser -u nobody -- env HOME=/nonexistent \
        XDG_CONFIG_DIRS=/etc/xdg:/usr/share/kde-settings/kde-profile/default/xdg \
        kreadconfig6 "$@"
}

attendu() { # $1 : description, $2 : valeur attendue, $3… : options de kreadconfig6
    local description=$1 valeur=$2 lu
    shift 2
    lu="$(reglage "$@")"
    if [[ "${lu}" == "${valeur}" ]]; then
        echo "${description} : ${lu}"
    else
        echec "${description} : « ${lu} » au lieu de « ${valeur} »"
    fi
}

# Polices de l'interface et du code, installées et trouvées par fontconfig
for police in Inter 'JetBrains Mono'; do
    trouvee="$(fc-match -f '%{family}' "${police}")"
    if [[ ",${trouvee}," == *",${police},"* ]]; then
        echo "Police ${police} : installée"
    else
        echec "police ${police} absente (fontconfig propose « ${trouvee} »)"
    fi
done
attendu "Police de l'interface" 'Inter,10,-1,5,50,0,0,0,0,0' --group General --key font
attendu "Police du code" 'JetBrains Mono,10,-1,5,50,0,0,0,0,0' --group General --key fixed

# Thème global « Ankh Sombre », avec le jeu de couleurs Ankh
sombre=/usr/share/plasma/look-and-feel/org.fedoraproject.fedoradark.desktop
attendu "Thème global par défaut" org.fedoraproject.fedoradark.desktop --group KDE --key LookAndFeelPackage
nom="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["KPlugin"]["Name"])' "${sombre}/metadata.json")"
[[ "${nom}" == "Ankh Sombre" ]] || echec "le thème global par défaut s'appelle « ${nom} »"
attendu "Jeu de couleurs du thème global" Ankh --file "${sombre}/contents/defaults" --group kdeglobals --group General --key ColorScheme
attendu "Jeu de couleurs Ankh présent" Ankh --file /usr/share/color-schemes/Ankh.colors --group General --key ColorScheme

# Barre flottante (menu et applications centrés entre deux espaceurs) et écran
# de chargement d'Ankh, dans tous les thèmes globaux qui en ont un : ceux de
# Fedora renommés « Ankh » et ceux de KDE (Breeze)
barres=0
for dossier in /usr/share/plasma/look-and-feel/*/; do
    theme="$(basename "${dossier}")"
    barre="${dossier}contents/layouts/org.kde.plasma.desktop-layout.js"
    if [[ -e "${barre}" ]]; then
        if [[ "$(grep -c '"org.kde.plasma.panelspacer"' "${barre}")" == 2 ]] && grep -q '^panel.floating = true' "${barre}" \
            && grep -q '^panel.opacity = "translucent"' "${barre}"; then
            barres=$((barres + 1))
        else
            echec "barre de ${theme} : pas celle d'Ankh"
        fi
    fi
    if [[ -e "${dossier}contents/splash/Splash.qml" ]]; then
        if grep -q 'images/ankh-logo.svg' "${dossier}contents/splash/Splash.qml" && [[ -f "${dossier}contents/splash/images/ankh-logo.svg" ]]; then
            echo "Écran de chargement d'Ankh : ${theme}"
        else
            echec "écran de chargement de ${theme} : pas celui d'Ankh"
        fi
    fi
done
echo "Barre d'Ankh dans ${barres} thème(s) global(aux)"
((barres >= 6)) || echec "barre d'Ankh dans ${barres} thème(s) global(aux) seulement (6 attendus : 3 de Fedora, 3 de KDE)"
for theme in fedora fedoradark fedoralight; do
    dossier="/usr/share/plasma/look-and-feel/org.fedoraproject.${theme}.desktop"
    attendu "Écran de chargement désigné par ${theme}" "org.fedoraproject.${theme}.desktop" --file "${dossier}/contents/defaults" --group ksplashrc --group KSplash --key Theme
done

# Assistant de premier démarrage (D-037) : « Breeze sombre », appliqué par son
# choix « Dark Theme », garde les couleurs d'Ankh ; son fond est celui d'Ankh ;
# la page « Bienvenue dans Ankh » est installée comme module de l'assistant
attendu "Jeu de couleurs de Breeze sombre" Ankh --file /usr/share/plasma/look-and-feel/org.kde.breezedark.desktop/contents/defaults --group kdeglobals --group General --key ColorScheme
for image in 5120x2880.png 1080x1920.png; do
    chemin="/usr/share/wallpapers/Next/contents/images/${image}"
    if python3 -c 'import sys; sys.exit(open(sys.argv[1], "rb").read(8) != b"\x89PNG\r\n\x1a\n")' "${chemin}" 2> /dev/null; then
        echo "Fond de l'assistant : ${image}"
    else
        echec "fond de l'assistant absent ou illisible : ${chemin}"
    fi
done
if [[ -e /usr/share/wallpapers/Next/metadata.json || -e /usr/share/wallpapers/Next/metadata.desktop ]]; then
    echec "le dossier du fond de l'assistant serait proposé comme fond d'écran"
fi
module=/usr/share/plasma/packages/org.ankh.plasmasetup.bienvenue
if python3 -c 'import json, sys; m = json.load(open(sys.argv[1])); sys.exit(not (m["KPackageStructure"] == "KDE/PlasmaSetup" and m["X-KDE-ParentApp"] == "org.kde.plasmasetup"))' "${module}/metadata.json" \
    && grep -q 'Bienvenue dans Ankh' "${module}/contents/ui/main.qml"; then
    echo "Page « Bienvenue dans Ankh » : installée"
else
    echec "page « Bienvenue dans Ankh » absente ou mal décrite : ${module}"
fi

# Breeze plus doux et Konsole aux couleurs d'Ankh
attendu "Opacité des menus" 85 --file breezerc --group Style --key MenuOpacity
attendu "Ombres des fenêtres" ShadowVeryLarge --file breezerc --group Common --key ShadowSize
attendu "Profil Konsole par défaut" Ankh.profile --file konsolerc --group 'Desktop Entry' --key DefaultProfile
attendu "Barre de menus de Konsole (réglage de Fedora gardé)" Disabled --file konsolerc --group MainWindow --key MenuBar
attendu "Couleurs du profil Konsole" Ankh --file /usr/share/konsole/Ankh.profile --group Appearance --key ColorScheme
[[ -f /usr/share/konsole/Ankh.colorscheme ]] || echec "couleurs Konsole d'Ankh absentes"

# Pas de message de Fedora qui conseille Toolbx et DNF au premier terminal
[[ -f /etc/skel/.config/toolbox/host-welcome-shown ]] || echec "message de bienvenue de Toolbx non désactivé pour les nouveaux comptes"

# D-042 : finitions au niveau de macOS et de Windows 11
# Thèmes clairs aux couleurs d'Ankh, et clair/sombre automatiques entre les
# deux thèmes d'Ankh
attendu "Jeu de couleurs Ankh Clair présent" AnkhClair --file /usr/share/color-schemes/AnkhClair.colors --group General --key ColorScheme
for theme in org.fedoraproject.fedora.desktop org.fedoraproject.fedoralight.desktop org.kde.breeze.desktop; do
    attendu "Jeu de couleurs de ${theme}" AnkhClair --file "/usr/share/plasma/look-and-feel/${theme}/contents/defaults" --group kdeglobals --group General --key ColorScheme
done
attendu "Thème clair automatique" org.fedoraproject.fedoralight.desktop --group KDE --key DefaultLightLookAndFeel
attendu "Thème sombre automatique" org.fedoraproject.fedoradark.desktop --group KDE --key DefaultDarkLookAndFeel
# « Ankh Signal », fond par défaut, en version claire et sombre : Plasma
# prend celle qui va avec le jeu de couleurs
for variante in images images_dark; do
    [[ -f "/usr/share/wallpapers/Ankh-Signal/contents/${variante}/3840x2160.jpg" ]] \
        || echec "fond « Ankh Signal » : version ${variante} absente"
done
# Recherche au milieu de l'écran, favoris du menu et applications épinglées
attendu "Recherche flottante" true --file krunnerrc --group General --key FreeFloating
favoris="$(reglage --file kicker-extra-favoritesrc --group General --key Prepend)"
if [[ "${favoris}" == "preferred://browser;ankh-vscode.desktop;"* ]]; then
    echo "Favoris du menu : ${favoris}"
else
    echec "favoris du menu : « ${favoris} »"
fi
attendu "Favoris de Fedora ignorés" true --file kicker-extra-favoritesrc --group General --key IgnoreDefaults
for barre in /usr/share/plasma/look-and-feel/*/contents/layouts/org.kde.plasma.desktop-layout.js; do
    grep -q '"applications:ankh-vscode.desktop"' "${barre}" || echec "applications épinglées absentes : ${barre}"
done
# Accueil de KDE (Welcome Center) : première page et page « Raccourcis utiles » d'Ankh
grep -q '^Icon=ankh-logo$' /usr/share/plasma/plasma-welcome/intro-customization.desktop \
    || echec "première page de l'accueil de KDE : logo d'Ankh absent"
grep -q 'Raccourcis utiles' /usr/share/plasma/plasma-welcome/extra-pages/01-Raccourcis.qml \
    || echec "page « Raccourcis utiles » de l'accueil de KDE absente"
# Image de compte d'Ankh pour chaque nouveau compte, enregistrée pour l'écran
# de connexion à la première session
if python3 -c 'import sys; sys.exit(open(sys.argv[1], "rb").read(8) != b"\x89PNG\r\n\x1a\n")' /etc/skel/.face.icon 2> /dev/null; then
    echo "Image de compte d'Ankh : /etc/skel/.face.icon"
else
    echec "image de compte d'Ankh absente ou illisible : /etc/skel/.face.icon"
fi
[[ -x /usr/libexec/ankh-image-de-compte ]] || echec "/usr/libexec/ankh-image-de-compte absent ou non exécutable"
attendu "Image de compte enregistrée à la première session" /usr/libexec/ankh-image-de-compte \
    --file /etc/xdg/autostart/ankh-image-de-compte.desktop --group 'Desktop Entry' --key Exec

if ((echecs > 0)); then
    echo "ÉCHEC : ${echecs} réglage(s) de l'identité visuelle manquant(s)" >&2
    exit 1
fi
echo "Identité visuelle d'Ankh en place."
