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

# Polices de l'interface (D-052, lot 1), du code, et de l'écran de connexion,
# installées et trouvées par fontconfig
for police in Selawik 'JetBrains Mono' Inter; do
    trouvee="$(fc-match -f '%{family}' "${police}")"
    if [[ ",${trouvee}," == *",${police},"* ]]; then
        echo "Police ${police} : installée"
    else
        echec "police ${police} absente (fontconfig propose « ${trouvee} »)"
        # Diagnostic : fichiers connus de fontconfig, et validité de ses caches
        fc-list : family file | grep -i -- "${police}" || echo "(fc-list ne connaît pas ${police})"
        FC_DEBUG=16 fc-match "${police}" 2>&1 | grep -E 'FcCacheTimeValid dir "/usr/share/fonts(/selawik)?"' || echo "(aucun cache lu pour /usr/share/fonts)"
    fi
done
attendu "Police de l'interface" 'Selawik,10.5,-1,5,50,0,0,0,0,0' --group General --key font
attendu "Petite police" 'Selawik,9,-1,5,50,0,0,0,0,0' --group General --key smallestReadableFont
attendu "Police des barres de titre" 'Selawik,9,-1,5,50,0,0,0,0,0' --group WM --key activeFont
attendu "Police du code" 'JetBrains Mono,10,-1,5,50,0,0,0,0,0' --group General --key fixed
# D-052, lot 1 : Selawik, ses trois graisses et sa licence
for graisse in Light Regular Bold; do
    [[ -f "/usr/share/fonts/selawik/Selawik-${graisse}.ttf" ]] || echec "Selawik ${graisse} absente"
done
[[ -f /usr/share/licenses/selawik/OFL.txt ]] || echec "licence de Selawik absente"
# Rendu des polices en niveaux de gris (rgba 5 : aucun sous-pixel ;
# hintstyle 1 : léger), décidé par fontconfig
rendu="$(fc-match -f '%{rgba} %{hintstyle} %{antialias}' Selawik)"
if [[ "${rendu}" == "5 1 True" ]]; then
    echo "Rendu des polices : niveaux de gris, contours légers (${rendu})"
else
    echec "rendu des polices : « ${rendu} » au lieu de « 5 1 True » (rgba, hintstyle, antialias)"
fi
attendu "Sous-pixels pour X11" none --group General --key XftSubPixel
attendu "Facteur des animations" 0.8333333 --group KDE --key AnimationDurationFactor
# D-054 : accent pris du fond d'écran ; chaque fond d'Ankh désigne le violet
# des jeux de couleurs d'Ankh (focus des listes : clair, puis sombre). Les
# fonds de KDE présents dans l'image (Altai, Mountain…) gardent leur couleur.
attendu "Accent depuis le fond d'écran" true --group General --key accentColorFromWallpaper
violets="$(for jeu in AnkhClair Ankh; do
    reglage --file "/usr/share/color-schemes/${jeu}.colors" --group Colors:View --key DecorationFocus
done | python3 -c 'import sys; print(" ".join("#%02x%02x%02x" % tuple(map(int, l.split(","))) for l in sys.stdin.read().split()))')"
fonds=0
for fiche in /usr/share/wallpapers/Ankh/metadata.json /usr/share/wallpapers/Ankh-*/metadata.json; do
    accent="$(python3 -c 'import json, sys
a = json.load(open(sys.argv[1])).get("X-KDE-PlasmaImageWallpaper-AccentColor", {})
print(a.get("Light", "absent"), a.get("Dark", "absent"))' "${fiche}")"
    if [[ "${accent}" == "${violets}" ]]; then
        fonds=$((fonds + 1))
    else
        echec "accent de $(basename "$(dirname "${fiche}")") : « ${accent} » au lieu de « ${violets} » (clair, sombre)"
    fi
done
((fonds > 0)) || echec "aucun fond d'écran d'Ankh trouvé"
echo "Accent d'Ankh (${violets}) désigné par ${fonds} fond(s) d'écran"
# Curseurs blancs d'Ankh, dans l'image et dans chaque thème global
for curseur in default left_ptr pointer text wait progress; do
    [[ -e "/usr/share/icons/Ankh-curseurs/cursors/${curseur}" ]] || echec "curseur « ${curseur} » absent d'Ankh-curseurs"
done
[[ -f /usr/share/icons/Ankh-curseurs/LICENSE ]] || echec "licence des curseurs d'Ankh absente"
attendu "Curseurs" Ankh-curseurs --file kcminputrc --group Mouse --key cursorTheme
attendu "Taille des curseurs" 24 --file kcminputrc --group Mouse --key cursorSize
for defauts in /usr/share/plasma/look-and-feel/*/contents/defaults; do
    attendu "Curseurs de $(basename "$(dirname "$(dirname "${defauts}")")")" Ankh-curseurs \
        --file "${defauts}" --group kcminputrc --group Mouse --key cursorTheme
done

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
for image in {images,images_dark}/{5120x2880,1080x1920}.png; do
    chemin="/usr/share/wallpapers/Next/contents/${image}"
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
    grep -q '"applications:com.valvesoftware.Steam.desktop"' "${barre}" || echec "Steam non épinglé avec Gaming : ${barre}"
done
# Accueil de KDE (Welcome Center) : première page et page « Raccourcis utiles » d'Ankh
grep -q '^Icon=ankh-logo$' /usr/share/plasma/plasma-welcome/intro-customization.desktop \
    || echec "première page de l'accueil de KDE : logo d'Ankh absent"
grep -q 'Raccourcis utiles' /usr/share/plasma/plasma-welcome/extra-pages/01-Raccourcis.qml \
    || echec "page « Raccourcis utiles » de l'accueil de KDE absente"
# Textes affichés par Ankh : vouvoiement (ma demande du 2026-10-10). En
# C.UTF-8, « è » est une lettre : « Complète » ne passe pas pour « te ».
if LC_ALL=C.UTF-8 grep -nE "(\"|=)[^\"]*\<(tu|ton|ta|tes|toi|te)\>" /usr/share/plasma/plasma-welcome/intro-customization.desktop \
    /usr/share/plasma/plasma-welcome/extra-pages/*.qml "${module}/contents/ui/main.qml" \
    /usr/share/plasma/packages/org.ankh.plasmasetup.options/contents/ui/main.qml \
    /usr/lib64/qt6/qml/org/ankh/composants/*.qml /usr/share/plasma/plasmoids/org.ankh.options/contents/ui/*.qml \
    /usr/share/applications/ankh-options.desktop /usr/libexec/ankh-options-reglages \
    /usr/share/ankh/options/gaming/applications/*.desktop /usr/share/ankh/options/gaming/wayland-sessions/*.desktop \
    /usr/libexec/ankh-flatpak /usr/share/applications/ai.storyteller.*.desktop \
    /usr/share/ankh/options/creation/applications/*.desktop /usr/libexec/ankh-craft; then
    echec "tutoiement dans un texte affiché par Ankh (lignes ci-dessus)"
fi
# Le message de la fenêtre du mot de passe, dans l'action polkit des options
if LC_ALL=C.UTF-8 grep -nE "<(message|description)>.*\<(tu|ton|ta|tes|toi|te)\>" /usr/share/polkit-1/actions/org.ankh.options.policy; then
    echec "tutoiement dans le message de l'action polkit des options (lignes ci-dessus)"
fi
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

# D-043 : écran de connexion d'Ankh, avec SDDM au lieu de Plasma Login
lien="$(readlink /etc/systemd/system/display-manager.service)"
[[ "$(basename "${lien}")" == sddm.service ]] || echec "le service d'affichage est « ${lien} », pas SDDM"
if rpm -q plasma-login-manager > /dev/null; then
    echec "Plasma Login est encore installé"
fi
attendu "Thème de SDDM" ankh --file /usr/lib/sddm/sddm.conf.d/ankh.conf --group Theme --key Current
theme=/usr/share/sddm/themes/ankh
attendu "Thème de SDDM en Qt 6" 6 --file "${theme}/metadata.desktop" --group SddmGreeterTheme --key QtVersion
for f in Main.qml fond.jpg faces/.face.icon; do
    [[ -s "${theme}/${f}" ]] || echec "thème de SDDM : ${f} absent"
done
# Le thème est chargé hors écran, en mode test de SDDM (sddm-greeter-qt6
# --test-mode --theme, src/greeter/GreeterApp.cpp de https://github.com/sddm/sddm) :
# toute erreur de son QML fait échouer le test. Il tourne jusqu'à être arrêté
# au bout de 20 secondes (code 124 de timeout) ; s'il s'arrête avant, c'est
# une erreur.
code=0
sortie="$(timeout 20 env QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software XDG_RUNTIME_DIR=/tmp \
    sddm-greeter-qt6 --test-mode --theme "${theme}" 2>&1)" || code=$?
if [[ ${code} -ne 124 ]] || grep -E "Main\.qml:[0-9]+" <<< "${sortie}"; then
    echo "${sortie}" >&2
    echec "l'écran de connexion d'Ankh ne se charge pas (code ${code})"
else
    echo "Écran de connexion d'Ankh : chargé par SDDM sans erreur"
fi

if ((echecs > 0)); then
    echo "ÉCHEC : ${echecs} réglage(s) de l'identité visuelle manquant(s)" >&2
    exit 1
fi
echo "Identité visuelle d'Ankh en place."
