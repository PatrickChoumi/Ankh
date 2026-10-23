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
# D-052, lot 2 : décoration des fenêtres d'Ankh, ses bibliothèques trouvées,
# choisie par défaut et dans chaque thème global
decoration=/usr/lib64/qt6/plugins/org.kde.kdecoration3/org.ankh.decoration.so
[[ -f "${decoration}" ]] || echec "décoration d'Ankh absente"
if ldd -r "${decoration}" 2>&1 | grep -E 'not found|undefined symbol'; then
    echec "la décoration d'Ankh ne trouve pas ses bibliothèques"
fi
attendu "Décoration des fenêtres" org.ankh.decoration --file kwinrc --group org.kde.kdecoration2 --key library
attendu "Boutons à gauche" M --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft
attendu "Boutons à droite" IAX --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight
for defauts in /usr/share/plasma/look-and-feel/*/contents/defaults; do
    attendu "Décoration de $(basename "$(dirname "$(dirname "${defauts}")")")" org.ankh.decoration \
        --file "${defauts}" --group kwinrc --group org.kde.kdecoration2 --key library
    attendu "Alt+Tab de $(basename "$(dirname "$(dirname "${defauts}")")")" org.ankh.alttab \
        --file "${defauts}" --group kwinrc --group WindowSwitcher --key LayoutName
done
# D-052, lot 7a : Alt+Tab d'Ankh, sélecteur de fenêtres de KWin, sans mise en
# avant de la fenêtre choisie
for fichier in metadata.json contents/ui/main.qml contents/ui/Selecteur.qml; do
    [[ -f "/usr/share/kwin-wayland/tabbox/org.ankh.alttab/${fichier}" ]] || echec "Alt+Tab d'Ankh : ${fichier} absent"
done
grep -q '"KPackageStructure": "KWin/WindowSwitcher"' /usr/share/kwin-wayland/tabbox/org.ankh.alttab/metadata.json \
    || echec "Alt+Tab d'Ankh : metadata.json n'est pas celui d'un sélecteur de fenêtres"
attendu "Sélecteur de fenêtres" org.ankh.alttab --file kwinrc --group TabBox --key LayoutName
# D-052, lot 7b : vue des tâches d'Ankh, effet de KWin allumé, ouvert par le
# bouton « Vue des tâches » de la barre ; les raccourcis de KDE ne changent pas
for fichier in metadata.json contents/ui/main.qml contents/ui/VueTaches.qml; do
    [[ -f "/usr/share/kwin-wayland/effects/org.ankh.vuetaches/${fichier}" ]] || echec "vue des tâches d'Ankh : ${fichier} absent"
done
grep -q '"KPackageStructure": "KWin/Effect"' /usr/share/kwin-wayland/effects/org.ankh.vuetaches/metadata.json \
    || echec "vue des tâches d'Ankh : metadata.json n'est pas celui d'un effet de KWin"
attendu "Vue des tâches allumée" true --file kwinrc --group Plugins --key org.ankh.vuetachesEnabled
[[ -f /usr/share/plasma/plasmoids/org.ankh.vuetaches/contents/ui/main.qml ]] \
    || echec "bouton « Vue des tâches » d'Ankh absent"
[[ ! -e /etc/skel/.config/kglobalshortcutsrc ]] \
    || echec "raccourcis de KDE changés pour les nouveaux comptes (/etc/skel/.config/kglobalshortcutsrc)"
# D-052, lot 7d : sons réduits, son de connexion
attendu "Son de connexion" Sound --file plasma_workspace.notifyrc --group Event/startkde --key Action
attendu "Son de la corbeille" None --file plasma_workspace.notifyrc --group "Event/Trash: emptied" --key Action
attendu "Son du chargeur branché" None --file powerdevil.notifyrc --group Event/pluggedin --key Action
attendu "Son des avertissements" Popup --file plasma_workspace.notifyrc --group Event/warning --key Action
# D-052, lot 7c : écran de déconnexion au dessin de la connexion d'Ankh, dans
# chaque thème global qui en a un (voile d'Ankh, boutons ronds d'Ankh)
for deconnexion in /usr/share/plasma/look-and-feel/*/contents/logout; do
    grep -q 'color: "#0d1117"' "${deconnexion}/Logout.qml" \
        || echec "écran de déconnexion de KDE sans le voile d'Ankh : ${deconnexion}/Logout.qml"
    grep -q 'Bouton de l.écran de déconnexion d.Ankh' "${deconnexion}/LogoutButton.qml" \
        || echec "boutons de déconnexion de KDE au lieu de ceux d'Ankh : ${deconnexion}/LogoutButton.qml"
done
# D-052, lot 7c : écran de verrouillage au dessin de la connexion d'Ankh
# (adapter-plasma.py), l'authentification de KDE intacte
verrou=/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen
[[ -f "${verrou}/HorlogeAnkh.qml" ]] || echec "écran de verrouillage : horloge d'Ankh absente"
grep -q '^        HorlogeAnkh {$' "${verrou}/LockScreenUi.qml" || echec "écran de verrouillage : horloge de KDE"
grep -q 'background.visible: false' "${verrou}/MainBlock.qml" || echec "écran de verrouillage : champ de mot de passe de KDE"
grep -q 'authenticator.respond(password)' "${verrou}/LockScreenUi.qml" || echec "écran de verrouillage : réponse à l'authentification absente"
attendu "Fenêtre choisie mise en avant" false --file kwinrc --group TabBox --key HighlightWindows
# D-052, lot 3 : style des contrôles d'Ankh, ses bibliothèques trouvées, chargé
# sous son nom, choisi par défaut et dans chaque thème global
style=/usr/lib64/qt6/plugins/styles/ankh6.so
[[ -f "${style}" ]] || echec "style d'Ankh absent"
if ldd -r "${style}" 2>&1 | grep -E 'not found|undefined symbol'; then
    echec "le style d'Ankh ne trouve pas ses bibliothèques"
fi
attendu "Fiche du style d'Ankh" Ankh --file /usr/share/kstyle/themes/ankh.themerc --group KDE --key WidgetStyle
attendu "Style des applications" Ankh --group KDE --key widgetStyle
for defauts in /usr/share/plasma/look-and-feel/*/contents/defaults; do
    attendu "Style de $(basename "$(dirname "$(dirname "${defauts}")")")" Ankh \
        --file "${defauts}" --group kdeglobals --group KDE --key widgetStyle
done
attendu "Opacité des menus du style d'Ankh" 85 --file ankhrc --group Style --key MenuOpacity
# Style QtQuick de KDE adapté (build_files/qqc2/adapter.py) : fichiers lus sur
# le disque et non dans le greffon compilé, et chaque adaptation présente
qqc2=/usr/lib64/qt6/qml/org/kde/desktop
if grep -n '^prefer ' "${qqc2}/qmldir" "${qqc2}/private/qmldir"; then
    echec "style QtQuick : la copie compilée passe encore avant les fichiers adaptés"
fi
grep -q "Interrupteur d'Ankh" "${qqc2}/private/SwitchIndicator.qml" || echec "style QtQuick : interrupteur de KDE, et non celui d'Ankh"
for fichier in CheckBox RadioButton Switch; do
    grep -q 'implicitIndicatorHeight - topPadding - contentHeight' "${qqc2}/${fichier}.qml" \
        || echec "style QtQuick : hauteur de ${fichier} non adaptée"
done
grep -q 'ListViewItemMinHeight' "${qqc2}/ItemDelegate.qml" || echec "style QtQuick : élément de liste de moins de 40 px"
grep -q 'font: Kirigami.Theme.smallFont' "${qqc2}/ToolTip.qml" || echec "style QtQuick : infobulle en police normale"
grep -q '__ankhAccent' "${qqc2}/Button.qml" || echec "style QtQuick : bouton mis en avant sans accent"
# Accent exact (focusColor) et blanc ou noir posé dessus, comme le style
# d'Ankh, et non la sélection de KDE (mon choix du 2026-10-23, D-052)
grep -q '__ankhSurAccent' "${qqc2}/Button.qml" || echec "style QtQuick : icône du bouton mis en avant sans couleur sur l'accent"
grep -q 'Kirigami.Theme.focusColor' "${qqc2}/private/SwitchIndicator.qml" || echec "style QtQuick : interrupteur à la couleur de sélection, et non à l'accent"
# Thème GTK Fluent au violet d'Ankh, clair et sombre, par défaut pour les
# nouveaux comptes et dans les réglages de GNOME lus sous Wayland
for feuille in gtk-3.0/gtk.css gtk-3.0/gtk-dark.css gtk-4.0/gtk.css gtk-4.0/gtk-dark.css; do
    [[ -f "/usr/share/themes/Fluent-Ankh/${feuille}" ]] || echec "thème GTK Fluent-Ankh : ${feuille} absente"
done
grep -qi '#7c3aed' /usr/share/themes/Fluent-Ankh/gtk-3.0/gtk.css || echec "thème GTK clair : violet d'Ankh absent"
grep -qi '#a78bfa' /usr/share/themes/Fluent-Ankh/gtk-3.0/gtk-dark.css || echec "thème GTK sombre : violet d'Ankh absent"
attendu "Thème GTK 3 des nouveaux comptes" Fluent-Ankh --file /etc/skel/.config/gtk-3.0/settings.ini --group Settings --key gtk-theme-name
attendu "Thème GTK 4 des nouveaux comptes" Fluent-Ankh --file /etc/skel/.config/gtk-4.0/settings.ini --group Settings --key gtk-theme-name
theme_gtk="$(GSETTINGS_BACKEND=memory gsettings get org.gnome.desktop.interface gtk-theme)"
if [[ "${theme_gtk}" == "'Fluent-Ankh'" ]]; then
    echo "Thème GTK dans les réglages de GNOME : ${theme_gtk}"
else
    echec "thème GTK dans les réglages de GNOME : ${theme_gtk}"
fi
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

# Barre d'Ankh (D-052, lot 4 : collée, 48 px, translucide, menu et
# applications centrés entre deux espaceurs, date sous l'heure ; lot 5 : le
# Démarrer d'Ankh à la place de Kickoff) et écran de chargement d'Ankh, dans
# tous les thèmes globaux qui en ont un : ceux de Fedora renommés « Ankh » et
# ceux de KDE (Breeze)
barres=0
for dossier in /usr/share/plasma/look-and-feel/*/; do
    theme="$(basename "${dossier}")"
    barre="${dossier}contents/layouts/org.kde.plasma.desktop-layout.js"
    if [[ -e "${barre}" ]]; then
        if [[ "$(grep -c '"org.kde.plasma.panelspacer"' "${barre}")" == 2 ]] && grep -q '^panel.floating = false' "${barre}" \
            && grep -q '^panel.height = 48$' "${barre}" && grep -q '^panel.opacity = "translucent"' "${barre}" \
            && grep -q '^var horloge = panel.addWidget("org.ankh.horloge")' "${barre}" \
            && ! grep -q 'org.kde.plasma.digitalclock' "${barre}" \
            && grep -q 'zone.writeConfig("hiddenItems", cachees.concat(\["org.kde.plasma.notifications"\]))' "${barre}" \
            && grep -q '^panel.addWidget("org.ankh.bureau")' "${barre}" \
            && grep -q '^taches.writeConfig("fill", false)' "${barre}" \
            && grep -q '^panel.addWidget("org.ankh.demarrer")' "${barre}" \
            && grep -q '^panel.addWidget("org.ankh.vuetaches")' "${barre}" \
            && ! grep -q 'org.kde.plasma.kickoff' "${barre}" \
            && grep -q '^var reglages = panel.addWidget("org.ankh.reglages")' "${barre}" \
            && ! grep -q 'globalShortcut' "${barre}" \
            && grep -q '"org.kde.plasma.networkmanagement", "org.kde.plasma.volume"' "${barre}"; then
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
attendu "Place des notifications" BottomRight --file plasmanotifyrc --group Notifications --key PopupPosition
[[ -f /usr/share/plasma/plasmoids/org.ankh.bureau/contents/ui/main.qml ]] || echec "bande « Afficher le bureau » d'Ankh absente"
# Paramètres rapides d'Ankh (D-052, lot 6a)
for fichier in metadata.json contents/ui/main.qml contents/ui/Etat.qml contents/ui/Son.qml contents/ui/Volet.qml; do
    [[ -f "/usr/share/plasma/plasmoids/org.ankh.reglages/${fichier}" ]] || echec "paramètres rapides d'Ankh : ${fichier} absent"
done
grep -q '"Id": "org.ankh.reglages"' /usr/share/plasma/plasmoids/org.ankh.reglages/metadata.json \
    || echec "paramètres rapides d'Ankh : identifiant de l'applet"
# Horloge d'Ankh (D-052, lot 6b) : heure, date, cloche ; notifications et
# calendrier dans son volet
for fichier in metadata.json contents/ui/main.qml contents/ui/Horloge.qml contents/ui/Centre.qml \
    contents/ui/Notification.qml contents/ui/Calendrier.qml; do
    [[ -f "/usr/share/plasma/plasmoids/org.ankh.horloge/${fichier}" ]] || echec "horloge d'Ankh : ${fichier} absent"
done
grep -q '"Id": "org.ankh.horloge"' /usr/share/plasma/plasmoids/org.ankh.horloge/metadata.json \
    || echec "horloge d'Ankh : identifiant de l'applet"
# Module QML commun d'Ankh (couleurs de WinUI, flèche, boutons, interrupteur,
# curseur), dont se servent les applets d'Ankh
for type in Couleurs Chevron BoutonDiscret Interrupteur Curseur; do
    grep -q "^${type} 1.0 ${type}.qml$" /usr/lib64/qt6/qml/org/ankh/commun/qmldir \
        && [[ -f "/usr/lib64/qt6/qml/org/ankh/commun/${type}.qml" ]] || echec "module org.ankh.commun : ${type} absent"
done
# Démarrer d'Ankh (D-052, lot 5) : paquet QML dérivé de Kickoff, ouvert par
# la touche Méta (X-Plasma-Provides), avec ses singletons déclarés (qmldir).
# Ses imports, ses types et les modèles de Kicker sont vérifiés à la
# construction (build_files/plasma/verifier-demarrer.sh).
demarrer=/usr/share/plasma/plasmoids/org.ankh.demarrer
if python3 -I -c 'import json, sys
meta = json.load(open(sys.argv[1], encoding="utf-8"))
sys.exit(meta["KPlugin"]["Id"] != "org.ankh.demarrer" or "org.kde.plasma.launchermenu" not in meta.get("X-Plasma-Provides", []))' \
    "${demarrer}/metadata.json" 2> /dev/null; then
    echo "Démarrer d'Ankh : présent, menu des applications de Plasma"
else
    echec "Démarrer d'Ankh absent, ou sans X-Plasma-Provides org.kde.plasma.launchermenu (${demarrer}/metadata.json)"
fi
for fichier in contents/ui/main.qml contents/ui/Demarrer.qml contents/ui/Modeles.qml contents/config/main.xml; do
    [[ -s "${demarrer}/${fichier}" ]] || echec "Démarrer d'Ankh : ${fichier} absent"
done
for singleton in Mesures ActionMenu; do
    grep -qx "singleton ${singleton} ${singleton}.qml" "${demarrer}/contents/ui/qmldir" \
        || echec "Démarrer d'Ankh : singleton ${singleton} non déclaré dans qmldir"
done
grep -q 'margin: Plasmoid.location === PlasmaCore.Types.Floating ? 0 : 12' \
    /usr/share/plasma/shells/org.kde.plasma.desktop/contents/applet/CompactApplet.qml \
    || echec "volets de la barre collés à la barre, et non à 12 px"
# Style Plasma d'Ankh (D-052, lot 4) : ses SVG, lisibles, choisi par défaut et
# dans chaque thème global
for svg in dialogs/background translucent/dialogs/background solid/dialogs/background widgets/tooltip \
    solid/widgets/tooltip widgets/panel-background solid/widgets/panel-background widgets/tasks; do
    fichier="/usr/share/plasma/desktoptheme/ankh/${svg}.svg"
    if [[ ! -s "${fichier}" ]] || ! python3 -I -c 'import sys, xml.etree.ElementTree as ET; ET.parse(sys.argv[1])' "${fichier}"; then
        echec "style Plasma d'Ankh : ${svg} absent ou illisible"
    fi
done
grep -q 'id="focus-bottom"' /usr/share/plasma/desktoptheme/ankh/widgets/tasks.svg || echec "style Plasma d'Ankh : bouton de l'application active absent"
# Icônes des applications de 32 px dans la barre de 48 (mon choix du
# 2026-10-22) : Plasma leur donne la hauteur du bouton moins les marges du
# haut et du bas de widgets/tasks (iconBox de Task.qml, plasma-desktop)
icone_tache="$(python3 -I -c '
import sys, xml.etree.ElementTree as ET
racine = ET.parse(sys.argv[1]).getroot()
hauteurs = {e.get("id"): float(e.get("height")) for e in racine.iter() if "hint" in e.get("id", "")}
print(round(48 - hauteurs["normal-hint-top-margin"] - hauteurs["normal-hint-bottom-margin"]))
' /usr/share/plasma/desktoptheme/ankh/widgets/tasks.svg)" || echec "style Plasma d'Ankh : marges des boutons de la barre illisibles"
[[ ${icone_tache} == 32 ]] || echec "icônes des applications de ${icone_tache} px dans la barre, au lieu de 32"
grep -q 'id="shadow-top"' /usr/share/plasma/desktoptheme/ankh/dialogs/background.svg || echec "style Plasma d'Ankh : ombre des volets absente"
attendu "Style Plasma" ankh --file plasmarc --group Theme --key name
for defauts in /usr/share/plasma/look-and-feel/*/contents/defaults; do
    attendu "Style Plasma de $(basename "$(dirname "$(dirname "${defauts}")")")" ankh \
        --file "${defauts}" --group plasmarc --group Theme --key name
done
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
    /usr/share/plasma/plasmoids/org.ankh.demarrer/contents/ui/*.qml /usr/share/plasma/plasmoids/org.ankh.demarrer/contents/ui/code/*.js \
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
