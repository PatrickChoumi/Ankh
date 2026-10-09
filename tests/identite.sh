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

# Barre flottante, menu et applications centrés entre deux espaceurs, dans
# les trois thèmes globaux d'Ankh
for theme in fedora fedoradark fedoralight; do
    barre="/usr/share/plasma/look-and-feel/org.fedoraproject.${theme}.desktop/contents/layouts/org.kde.plasma.desktop-layout.js"
    if [[ "$(grep -c '"org.kde.plasma.panelspacer"' "${barre}")" == 2 ]] && grep -q '^panel.floating = true' "${barre}"; then
        echo "Barre d'Ankh : ${theme}"
    else
        echec "barre de ${barre} : pas celle d'Ankh"
    fi
done

# Breeze plus doux et Konsole aux couleurs d'Ankh
attendu "Opacité des menus" 85 --file breezerc --group Style --key MenuOpacity
attendu "Ombres des fenêtres" ShadowVeryLarge --file breezerc --group Common --key ShadowSize
attendu "Profil Konsole par défaut" Ankh.profile --file konsolerc --group 'Desktop Entry' --key DefaultProfile
attendu "Couleurs du profil Konsole" Ankh --file /usr/share/konsole/Ankh.profile --group Appearance --key ColorScheme
[[ -f /usr/share/konsole/Ankh.colorscheme ]] || echec "couleurs Konsole d'Ankh absentes"

# Pas de message de Fedora qui conseille Toolbx et DNF au premier terminal
[[ -f /etc/skel/.config/toolbox/host-welcome-shown ]] || echec "message de bienvenue de Toolbx non désactivé pour les nouveaux comptes"

if ((echecs > 0)); then
    echo "ÉCHEC : ${echecs} réglage(s) de l'identité visuelle manquant(s)" >&2
    exit 1
fi
echo "Identité visuelle d'Ankh en place."
