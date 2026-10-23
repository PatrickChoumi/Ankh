# shellcheck shell=bash disable=SC2154
# (SC2154 : repo, work… viennent de tests/vm/run.sh, qui charge ce fichier)
# Banc de l'interface d'Ankh (D-052, lot 0), chargé par tests/vm/run.sh, qui
# fournit log, die, vm, vm_copier, in_session, launch_in_session,
# kwin_script, activate_window, close_app, monitor, souris et screenshot.
#
# check_interface, dans la session du compte de test :
#   1. relève les réglages de l'interface (curseur, barre de titre, barre
#      des tâches, horloge, notifications, animations) ;
#   2. ouvre la galerie des contrôles (widget org.ankh.banc, installé dans
#      ce compte seulement) et lit la police et les tailles que donne le
#      style des applications de KDE ;
#   3. capture chaque surface (captures « ui-<thème>-<échelle>-<surface> ») :
#      toutes en sombre à 100 %, les principales en clair, puis à 125 et
#      150 % ;
#   4. sur un fond d'écran noir, mesure sur l'image : coins d'une fenêtre,
#      du menu et des contrôles, bouton Fermer survolé, barre des tâches ;
#   5. compare tout aux valeurs de Windows 11 (build_files/interface/
#      jetons.toml) dans le rapport ui-rapport.md, joint aux captures. Le
#      test échoue si une mesure obligatoire est hors cible.
# Une surface ou une mesure impossible est signalée sans arrêter le banc :
# la mesure apparaît alors « non mesurée » dans le rapport.

banc_dossier="$repo/tests/vm/banc"
banc_mesures="$work/captures/ui-mesures.tsv"
banc_images="$work/mesures"
banc_galerie_journal="$work/galerie.txt"
banc_compte=ankhvm

# Une mesure : son identifiant dans jetons.toml, et sa valeur.
banc_noter() {
    printf '%s\t%s\n' "$1" "$2" >> "$banc_mesures"
    echo "Mesure : $1 = $2"
}

# Commande dont l'échec est signalé sans arrêter le banc :
# banc_essayer DESCRIPTION COMMANDE…
banc_essayer() {
    local quoi=$1
    shift
    if ! "$@"; then
        echo "($quoi : impossible)"
    fi
}

# Réglage de KDE tel que le compte le voit (mêmes dossiers que la session) :
# banc_reglage FICHIER GROUPE CLÉ DÉFAUT.
banc_reglage() {
    in_session "$banc_compte" env "XDG_CONFIG_DIRS=/home/$banc_compte/.config/kdedefaults:/etc/xdg:/usr/share/kde-settings/kde-profile/default/xdg" \
        kreadconfig6 --file "$1" --group "$2" --key "$3" --default "$4"
}

# Script de Plasma ; affiche ce qu'il écrit avec print() (méthode
# evaluateScript, shell/shellcorona.cpp de plasma-workspace).
# Les « return 1 » rendent l'échec visible aussi dans un « if », où bash
# ignore « set -e ».
banc_plasma() {
    local sortie
    sortie=$(in_session "$banc_compte" busctl --user --json=short call org.kde.plasmashell /PlasmaShell \
        org.kde.PlasmaShell evaluateScript s "$1") || return 1
    jq -r '.data[0]' <<< "$sortie"
}

# Script de KWin ; affiche ses lignes qui portent l'étiquette, sans elle.
banc_kwin() { # $1 : nom, $2 : étiquette, $3 : script
    local sortie
    sortie=$(kwin_script "$banc_compte" "$1" "$2" "$3")
    sed -n "s/.*$2 //p" <<< "$sortie"
}

banc_session() { # méthode D-Bus de la session : busctl --user call …
    in_session "$banc_compte" busctl --user call "$@" > /dev/null
}

banc_mesurer() {
    python3 "$banc_dossier/mesurer.py" "$@"
}

# Capture au format PPM pour les mesures, et sa copie en PNG jointe au run
# (ui-mesure-…), pour vérifier les mesures à l'œil.
banc_image() {
    local fichier="$banc_images/$1.ppm"
    monitor "screendump $fichier"
    [[ -s $fichier ]] || die "capture de mesure impossible : $fichier"
    screenshot "ui-mesure-$1" > /dev/null
    echo "$fichier"
}

# Dolphin ouvert, à une place et une taille fixes (en pixels de Plasma),
# au premier plan : banc_dolphin X Y LARGEUR HAUTEUR.
banc_dolphin() {
    if ! vm pgrep -u "$banc_compte" -x dolphin > /dev/null; then
        launch_in_session "$banc_compte" dolphin "/home/$banc_compte"
        sleep 10
    fi
    # Dolphin seule devant le fond noir : les autres fenêtres sont réduites
    # (la galerie, ouverte juste au-dessus de Dolphin, empêchait de trouver
    # son bord haut, et donc le rayon de ses coins : runs 39424185717 et
    # 39575978529). banc_bureau non les rend ensuite.
    banc_kwin ankh-banc-placer ANKH-BANC-PLACEE "for (const w of workspace.windowList()) {
    if (!w.normalWindow) {
        continue;
    }
    if (String(w.desktopFileName) === 'org.kde.dolphin') {
        w.minimized = false;
        w.setMaximize(false, false);
        w.frameGeometry = {x: $1, y: $2, width: $3, height: $4};
        workspace.activeWindow = w;
        console.warn('ANKH-BANC-PLACEE ' + w.caption);
    } else {
        w.minimized = true;
    }
}"
    sleep 3
}

# Bureau dégagé : toutes les fenêtres réduites par KWin (oui), puis rendues
# (non). La méthode showDesktop de KWin, appelée par D-Bus, ne les masquait
# pas (run 38695602550).
banc_bureau() { # $1 : oui | non
    local reduire=true
    [[ $1 == oui ]] || reduire=false
    banc_kwin ankh-banc-bureau ANKH-BANC-BUREAU "for (const w of workspace.windowList()) {
    if (w.normalWindow) {
        w.minimized = $reduire;
    }
}
console.warn('ANKH-BANC-BUREAU $1');" > /dev/null
    sleep 2
}

# Galerie au premier plan ; affiche la place de son contenu à l'écran :
# X Y LARGEUR HAUTEUR.
banc_galerie_devant() {
    banc_kwin ankh-banc-galerie ANKH-BANC-GALERIE "for (const w of workspace.windowList()) {
    if (w.normalWindow && String(w.resourceClass).includes('plasmawindowed')) {
        w.minimized = false;
        workspace.activeWindow = w;
        const c = w.clientGeometry;
        console.warn('ANKH-BANC-GALERIE ' + [c.x, c.y, c.width, c.height].map(Math.round).join(' '));
    }
}"
    sleep 2
}

# 1. Réglages lus dans la session (valeurs par défaut de KDE s'ils sont absents).
banc_reglages() {
    local valeur alignement decoration panneau hauteur flottante position date
    log "Banc de l'interface (D-052) : réglages"
    if valeur=$(banc_reglage kcminputrc Mouse cursorTheme breeze_cursors); then
        banc_noter curseur.theme "$valeur"
    fi
    if valeur=$(banc_reglage kcminputrc Mouse cursorSize 24); then
        banc_noter curseur.taille "$valeur"
    fi
    if valeur=$(banc_reglage kdeglobals KDE AnimationDurationFactor 1); then
        banc_noter animations.facteur "$valeur"
    fi
    # Décoration des fenêtres : celle d'Ankh (D-052, lot 2) aligne toujours
    # le titre à gauche ; Breeze suit son réglage TitleAlignment
    # (kdecoration/breezesettingsdata.kcfg de breeze)
    if decoration=$(banc_reglage kwinrc org.kde.kdecoration2 library org.kde.breeze); then
        echo "Décoration des fenêtres : $decoration"
    fi
    if [[ ${decoration:-} == org.ankh.decoration ]]; then
        banc_noter fenetre.titre.alignement gauche
    elif alignement=$(banc_reglage breezerc Windeco TitleAlignment AlignCenterFullWidth); then
        case $alignement in
            AlignLeft) valeur=gauche ;;
            AlignRight) valeur=droite ;;
            *) valeur=centre ;;
        esac
        banc_noter fenetre.titre.alignement "$valeur"
    fi
    # Boutons de la barre de titre (src/kcms/decoration/kwindecorationsettings.kcfg de KWin)
    if valeur=$(banc_reglage kwinrc org.kde.kdecoration2 ButtonsOnLeft MS); then
        banc_noter fenetre.boutons.gauche "$valeur"
    fi
    if valeur=$(banc_reglage kwinrc org.kde.kdecoration2 ButtonsOnRight HIAX); then
        banc_noter fenetre.boutons.droite "$valeur"
    fi
    # PopupPosition (libnotificationmanager/kcfg/notificationsettings.kcfg de plasma-workspace)
    if valeur=$(banc_reglage plasmanotifyrc Notifications PopupPosition CloseToWidget); then
        banc_noter notifications.position "$valeur"
    fi
    # Barre des tâches et horloge, telles que Plasma les a (dateDisplayFormat :
    # applets/digital-clock/main.xml de plasma-workspace, 0 par défaut).
    if panneau=$(banc_plasma 'var p = panels()[0];
var c = p.widgets("org.kde.plasma.digitalclock")[0];
var date = "absente";
if (c) { c.currentConfigGroup = ["Appearance"]; date = c.readConfig("dateDisplayFormat", "0"); }
print([p.height, p.floating ? "oui" : "non", p.location, date].join(" "));'); then
        echo "Barre des tâches : $panneau"
        read -r hauteur flottante position date <<< "$panneau"
        banc_noter barre.hauteur "$hauteur"
        banc_noter barre.flottante "$flottante"
        banc_noter barre.position "$position"
        case $date in
            Adaptive) date=0 ;;
            BesideTime) date=1 ;;
            BelowTime) date=2 ;;
        esac
        banc_noter barre.horloge.date "$date"
    else
        echo "(barre des tâches : script de Plasma impossible)"
    fi
}

# 2. Galerie des contrôles : copiée dans le compte de test, ouverte, puis ses
# mesures lues dans le journal de la session.
banc_galerie() {
    local fichier dossier debut lignes etiquette mesure
    log "Banc de l'interface (D-052) : galerie des contrôles"
    dossier="/home/$banc_compte/.local/share/plasma/plasmoids/org.ankh.banc"
    vm "install -d $dossier/contents/ui"
    for fichier in metadata.json contents/ui/main.qml contents/ui/Galerie.qml; do
        vm_copier "$banc_dossier/org.ankh.banc/$fichier" "$dossier/$fichier"
    done
    vm "chown -R $banc_compte:$banc_compte /home/$banc_compte/.local"
    debut=$(vm date +%s)
    launch_in_session "$banc_compte" plasmawindowed org.ankh.banc
    sleep 15
    if ! lignes=$(vm "journalctl --no-pager -b --since=@$debut _UID=$(vm id -u "$banc_compte") --grep ANKH-BANC --output cat"); then
        echo "(galerie : aucune mesure dans le journal de la session)"
        : > "$banc_galerie_journal"
        return
    fi
    sed -n 's/.*\(ANKH-BANC\)/\1/p' <<< "$lignes" > "$banc_galerie_journal"
    cat "$banc_galerie_journal"
    while read -r etiquette mesure; do
        if [[ $etiquette == ANKH-BANC && $mesure == *=* ]]; then
            banc_noter "${mesure%%=*}" "${mesure#*=}"
        fi
    done < "$banc_galerie_journal"
}

# 3. Une surface ouverte, capturée (« PRÉFIXE-SURFACE »), puis refermée.
banc_surface() { # $1 : préfixe, $2 : surface, $3 : hauteur de la barre
    local nom="$1-$2" barre=${3:-44}
    case $2 in
        bureau)
            banc_bureau oui
            screenshot "$nom"
            banc_bureau non
            ;;
        demarrer)
            banc_essayer "menu" banc_session org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell activateLauncherMenu
            sleep 4
            screenshot "$nom"
            monitor 'sendkey esc'
            sleep 2
            ;;
        menu-bureau)
            banc_bureau oui
            souris clic-droit 900 300
            sleep 2
            screenshot "$nom"
            monitor 'sendkey esc'
            sleep 1
            banc_bureau non
            ;;
        dolphin)
            activate_window org.kde.dolphin
            sleep 2
            screenshot "$nom"
            ;;
        menu-application)
            # F10 : le menu principal de Dolphin (menu « hamburger »)
            activate_window org.kde.dolphin
            sleep 1
            monitor 'sendkey f10'
            sleep 3
            screenshot "$nom"
            monitor 'sendkey esc'
            sleep 1
            ;;
        dialogue)
            # Alt+Entrée : les propriétés du dossier ouvert, un dialogue de
            # Qt avec onglets, champs et boutons
            activate_window org.kde.dolphin
            sleep 1
            raccourci alt ret
            sleep 4
            screenshot "$nom"
            monitor 'sendkey esc'
            sleep 2
            ;;
        reglages)
            launch_in_session "$banc_compte" systemsettings
            sleep 15
            screenshot "$nom"
            close_app "$banc_compte" systemsettings
            ;;
        konsole)
            launch_in_session "$banc_compte" konsole
            sleep 8
            screenshot "$nom"
            close_app "$banc_compte" konsole
            ;;
        galerie)
            banc_galerie_devant > /dev/null
            screenshot "$nom"
            ;;
        notification)
            banc_essayer "notification" banc_session org.freedesktop.Notifications /org/freedesktop/Notifications \
                org.freedesktop.Notifications Notify 'susssasa{sv}i' Ankh 0 ankh-logo "Mise à jour prête" \
                "Elle s'appliquera au prochain redémarrage que vous choisirez." 0 0 8000
            sleep 2
            screenshot "$nom"
            ;;
        volume)
            banc_essayer "volume" banc_session org.kde.plasmashell /org/kde/osdService org.kde.osdService volumeChanged i 60
            sleep 1
            screenshot "$nom"
            ;;
        parametres-rapides)
            # Paramètres rapides d'Ankh (D-052, lot 6a) : Windows+A
            monitor 'sendkey meta_l-a'
            sleep 3
            screenshot "$nom"
            monitor 'sendkey esc'
            sleep 1
            ;;
        calendrier)
            # Horloge : à droite de la barre, avant « Afficher le bureau »
            souris clic 1200 $((800 - barre / 2))
            sleep 3
            screenshot "$nom"
            monitor 'sendkey esc'
            sleep 1
            ;;
        infobulle)
            souris survol 640 $((800 - barre / 2))
            sleep 3
            screenshot "$nom"
            souris survol 1279 400
            sleep 1
            ;;
        alt-tab)
            # Alt tenu, Tab tapé : le sélecteur de fenêtres reste affiché tant
            # qu'Alt est tenu (« sendkey alt-tab », qui envoie les deux touches
            # ensemble, ne l'affichait pas : run 38695602550)
            qmp_entree touche appui alt
            qmp_entree touche appui tab
            qmp_entree touche relache tab
            sleep 2
            screenshot "$nom"
            qmp_entree touche relache alt
            sleep 2
            ;;
        vue-ensemble)
            banc_essayer "vue d'ensemble" banc_session org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component invokeShortcut s Overview
            sleep 3
            screenshot "$nom"
            banc_essayer "fin de la vue d'ensemble" banc_session org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component invokeShortcut s Overview
            sleep 2
            ;;
        recherche)
            banc_essayer "recherche" banc_session org.kde.krunner /App org.kde.krunner.App query s code
            sleep 4
            screenshot "$nom"
            # Échap ne la fermait pas toujours (captures suivantes du run
            # 38695602550) : KRunner est arrêté ; D-Bus le relance au besoin.
            monitor 'sendkey esc'
            sleep 1
            close_app "$banc_compte" krunner
            ;;
        deconnexion)
            # Écran de déconnexion, refermé sans se déconnecter : Échap, puis,
            # s'il reste là, son programme est arrêté avant son compte à rebours.
            banc_essayer "écran de déconnexion" banc_session org.kde.LogoutPrompt /LogoutPrompt org.kde.LogoutPrompt promptLogout
            sleep 4
            screenshot "$nom"
            monitor 'sendkey esc'
            sleep 2
            if vm pgrep -u "$banc_compte" -f ksmserver-logout-greeter > /dev/null; then
                vm pkill -u "$banc_compte" -f ksmserver-logout-greeter
                sleep 2
            fi
            ;;
        *)
            die "surface inconnue du banc : $2"
            ;;
    esac
}

# 4. Mesures sur l'image, sur un fond d'écran noir.
banc_pixels() {
    local geometrie fx fy fw fh cx cy cw ch titre image largeur hauteur couleur espace volets ligne
    local classe type vx vy vw vh galerie gx gy nom x y l h essai accent
    log "Banc de l'interface (D-052) : mesures sur l'image"
    # D-054 : l'accent suit le fond d'écran ; il garde celui d'Ankh pendant
    # les mesures, sur fond noir, puis le réglage reprend sa valeur. Plasma le
    # relit à chaque changement notifié (shell/shellcorona.cpp de
    # plasma-workspace). Il est réécrit, pas effacé : effacer une clé que
    # /etc/xdg définit la masque (« [$d] » de KConfig, vu avec kwriteconfig6).
    if ! accent=$(banc_reglage kdeglobals General accentColorFromWallpaper false); then
        echo "(accent : réglage illisible, remis ensuite à la valeur d'Ankh)"
        accent=true
    fi
    banc_essayer "accent figé" in_session "$banc_compte" kwriteconfig6 --notify \
        --file kdeglobals --group General --key accentColorFromWallpaper false
    banc_essayer "fond d'écran noir" banc_plasma 'for (const d of desktops()) {
    d.wallpaperPlugin = "org.kde.color";
    d.currentConfigGroup = ["Wallpaper", "org.kde.color", "General"];
    d.writeConfig("Color", "0,0,0");
}'
    sleep 5
    souris survol 1279 400
    # Fenêtre : Dolphin, à une place connue
    banc_dolphin 200 120 880 520
    geometrie=$(banc_kwin ankh-banc-geometrie ANKH-BANC-FENETRE "for (const w of workspace.windowList()) {
    if (w.normalWindow && String(w.desktopFileName) === 'org.kde.dolphin') {
        const f = w.frameGeometry, c = w.clientGeometry;
        console.warn('ANKH-BANC-FENETRE ' + [f.x, f.y, f.width, f.height, c.x, c.y, c.width, c.height].map(Math.round).join(' '));
    }
}")
    echo "Dolphin (cadre, puis contenu) : $geometrie"
    if read -r fx fy fw fh cx cy cw ch <<< "$geometrie" && [[ -n $ch ]]; then
        titre=$((cy - fy))
        banc_noter fenetre.barre_de_titre.hauteur "$titre"
        banc_noter fenetre.bord.gauche $((cx - fx))
        banc_noter fenetre.bord.droit $((fx + fw - cx - cw))
        banc_noter fenetre.bord.bas $((fy + fh - cy - ch))
        image=$(banc_image fenetre)
        banc_noter fenetre.coin.rayon "$(banc_mesurer coin "$image" "$fx" "$fy" "$fw" "$fh")"
        banc_noter couleur.barre_de_titre "$(banc_mesurer couleur "$image" $((fx + fw * 3 / 4)) $((fy + titre / 2)))"
        banc_noter couleur.fenetre "$(banc_mesurer couleur "$image" $((fx + fw - 60)) $((fy + fh - 80)))"
        # Bouton Fermer survolé : la zone rouge, en haut à droite
        souris survol $((fx + fw - 15)) $((fy + titre / 2))
        sleep 2
        image=$(banc_image fermer)
        read -r largeur hauteur couleur <<< "$(banc_mesurer fermer "$image" $((fx + fw - 120)) "$fy" $((fx + fw)) "$cy")"
        banc_noter fenetre.fermer.largeur "$largeur"
        banc_noter fenetre.fermer.hauteur "$hauteur"
        banc_noter fenetre.fermer.couleur "$couleur"
        souris survol 1279 400
        sleep 1
    else
        echo "(fenêtre : place de Dolphin inconnue)"
    fi
    # Barre des tâches : colonne à gauche, sur l'espaceur
    image=$(banc_image barre)
    read -r espace hauteur couleur <<< "$(banc_mesurer barre "$image" 24)"
    banc_noter barre.marge_bas "$espace"
    banc_noter barre.hauteur_visible "$hauteur"
    banc_noter couleur.barre "$couleur"
    # Bouton de l'application active (Dolphin) : trait d'accent et rectangle
    local trait_l trait_e boite_l boite_h icone_l icone_h
    read -r trait_l trait_e boite_l boite_h icone_l icone_h <<< "$(banc_mesurer tache "$image" 48)"
    banc_noter barre.tache.trait.longueur "$trait_l"
    banc_noter barre.tache.trait.epaisseur "$trait_e"
    banc_noter barre.tache.rectangle.largeur "$boite_l"
    banc_noter barre.tache.rectangle.hauteur "$boite_h"
    if [[ $icone_l == "?" ]]; then
        banc_noter barre.tache.icone.dessin "?"
    else
        banc_noter barre.tache.icone.dessin "${icone_l}×${icone_h}"
    fi
    # Volet du menu : la fenêtre de plasmashell qui n'est ni la barre ni le
    # bureau. Les fenêtres sont d'abord réduites : le menu doit se détacher
    # sur le fond noir (Dolphin, derrière lui, faussait son bord haut : run
    # 38709938834).
    banc_bureau oui
    banc_essayer "menu" banc_session org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell activateLauncherMenu
    # Le menu peut mettre plus de 4 secondes à s'ouvrir (run 38702400701 :
    # absent pour KWin, mais ouvert sur l'image prise juste après) : KWin
    # est interrogé jusqu'à trois fois.
    for essai in 1 2 3; do
        sleep 4
        volets=$(banc_kwin ankh-banc-volets ANKH-BANC-VOLET "for (const w of workspace.windowList()) {
    const f = w.frameGeometry;
    const type = w.dock ? 'barre' : (w.desktopWindow ? 'bureau' : (w.normalWindow ? 'fenetre' : 'autre'));
    console.warn('ANKH-BANC-VOLET ' + w.resourceClass + ' ' + type + ' ' + [f.x, f.y, f.width, f.height].map(Math.round).join(' '));
}")
        echo "Fenêtres vues par KWin, menu ouvert (essai $essai) :"
        echo "$volets"
        if grep -q 'plasmashell autre' <<< "$volets"; then
            break
        fi
    done
    image=$(banc_image volet)
    local haut_barre="" centre_barre="" erreurs_qml
    while read -r classe type vx vy vw vh; do
        if [[ $classe == *plasmashell && $type == barre ]]; then
            haut_barre=$vy
            # La barre couvre toute la largeur de l'écran (lot 4)
            centre_barre=$((vx + vw / 2))
        fi
    done <<< "$volets"
    while read -r classe type vx vy vw vh; do
        if [[ $classe == *plasmashell && $type == autre && ${vh:-0} -gt 200 ]]; then
            banc_noter volet.rayon "$(banc_mesurer coin "$image" "$vx" "$vy" "$vw" "$vh")"
            # Écart entre le bas du menu et le haut de la barre
            if [[ -n $haut_barre ]]; then
                banc_noter volet.ecart_barre $((haut_barre - vy - vh))
            fi
            # Démarrer d'Ankh (lot 5) : taille du volet visible, et place de
            # son centre par rapport à celui de l'écran
            banc_noter demarrer.largeur "$vw"
            banc_noter demarrer.hauteur "$vh"
            if [[ -n $centre_barre ]]; then
                banc_noter demarrer.decalage_centre $((vx + vw / 2 - centre_barre))
            fi
            break
        fi
    done <<< "$volets"
    # Avertissements QML du Démarrer dans le journal de la session : une
    # erreur QML ne fait pas tomber Plasma (recherche du lot 5, § 4). grep ne
    # rend 1 que s'il ne trouve rien, ce qui n'est pas une erreur ici.
    if erreurs_qml=$(vm "set -o pipefail; journalctl --no-pager -b _UID=$(vm id -u "$banc_compte") --output cat \
        | { grep -E 'plasmoids/org\.ankh\.demarrer/[^ ]*\.qml:[0-9]+' || [ \$? -eq 1 ]; }"); then
        if [[ -n $erreurs_qml ]]; then
            echo "Avertissements QML du Démarrer :"
            echo "$erreurs_qml"
            banc_noter demarrer.erreurs_qml "$(wc -l <<< "$erreurs_qml")"
        else
            banc_noter demarrer.erreurs_qml 0
        fi
    else
        echo "(Démarrer : journal de la session illisible)"
    fi
    monitor 'sendkey esc'
    sleep 2
    # Paramètres rapides d'Ankh (lot 6a) : Windows+A, puis la fenêtre de
    # plasmashell qui n'est ni la barre ni le bureau, comme pour le menu
    monitor 'sendkey meta_l-a'
    for essai in 1 2 3; do
        sleep 3
        volets=$(banc_kwin ankh-banc-reglages ANKH-BANC-VOLET "for (const w of workspace.windowList()) {
    const f = w.frameGeometry;
    const type = w.dock ? 'barre' : (w.desktopWindow ? 'bureau' : (w.normalWindow ? 'fenetre' : 'autre'));
    console.warn('ANKH-BANC-VOLET ' + w.resourceClass + ' ' + type + ' ' + [f.x, f.y, f.width, f.height].map(Math.round).join(' '));
}")
        if grep -q 'plasmashell autre' <<< "$volets"; then
            break
        fi
    done
    echo "Fenêtres vues par KWin, paramètres rapides ouverts :"
    echo "$volets"
    while read -r classe type vx vy vw vh; do
        if [[ $classe == *plasmashell && $type == autre && ${vh:-0} -gt 100 ]]; then
            banc_noter reglages.largeur "$vw"
            banc_noter reglages.bord_droit $((1280 - vx - vw))
            if [[ -n $haut_barre ]]; then
                banc_noter reglages.ecart_barre $((haut_barre - vy - vh))
            fi
            break
        fi
    done <<< "$volets"
    monitor 'sendkey esc'
    sleep 2
    banc_bureau non
    # Contrôles de la zone noire de la galerie
    galerie=$(banc_galerie_devant)
    if read -r gx gy _ _ <<< "$galerie" && [[ -n $gy ]]; then
        image=$(banc_image galerie)
        while read -r ligne nom x y l h; do
            if [[ $ligne == ANKH-BANC-PLACE ]]; then
                banc_noter "controle.$nom.rayon" "$(banc_mesurer coin "$image" $((gx + x)) $((gy + y)) "$l" "$h")"
            fi
        done < "$banc_galerie_journal"
    else
        echo "(galerie : fenêtre introuvable)"
    fi
    banc_essayer "fond d'écran d'Ankh" banc_plasma 'for (const d of desktops()) { d.wallpaperPlugin = "org.kde.image"; }'
    banc_essayer "accent rendu au fond d'écran" in_session "$banc_compte" kwriteconfig6 --notify \
        --file kdeglobals --group General --key accentColorFromWallpaper "$accent"
    sleep 5
}

# Échelle de l'écran, par kscreen-doctor (1, 1.25, 1.5…).
banc_echelle() {
    local sortie
    sortie=$(in_session "$banc_compte" kscreen-doctor -j) || return 1
    sortie=$(jq -r '[.outputs[] | select(.enabled)][0].name' <<< "$sortie") || return 1
    [[ -n $sortie && $sortie != null ]] || return 1
    in_session "$banc_compte" kscreen-doctor "output.$sortie.scale.$1" > /dev/null || return 1
    sleep 8
}

check_interface() {
    local surface barre
    log "Banc de l'interface (D-052) : captures et mesures, comparées à Windows 11"
    mkdir -p "$banc_images"
    : > "$banc_mesures"
    for surface in konsole systemsettings plasma-welcome plasma-discover; do
        close_app "$banc_compte" "$surface"
    done
    banc_reglages
    barre=$(sed -n 's/^barre\.hauteur\t//p' "$banc_mesures")
    banc_galerie
    banc_dolphin 200 120 880 520
    for surface in bureau demarrer menu-bureau dolphin menu-application dialogue reglages konsole galerie \
        notification volume parametres-rapides calendrier infobulle alt-tab vue-ensemble recherche deconnexion; do
        banc_surface ui-sombre-100 "$surface" "$barre"
    done
    banc_pixels
    # Thème clair, puis retour au thème sombre par défaut (comme check_identity)
    banc_essayer "thème clair" in_session "$banc_compte" plasma-apply-lookandfeel -a org.fedoraproject.fedoralight.desktop
    sleep 10
    banc_dolphin 200 120 880 520
    for surface in bureau demarrer menu-bureau dolphin menu-application dialogue reglages galerie notification \
        parametres-rapides; do
        banc_surface ui-clair-100 "$surface" "$barre"
    done
    banc_essayer "thème sombre" in_session "$banc_compte" plasma-apply-lookandfeel -a org.fedoraproject.fedoradark.desktop
    sleep 10
    # Échelles de 125 et 150 % : Dolphin placé dans l'écran plus petit (en
    # pixels de Plasma : 1024×640, puis 853×533)
    if banc_echelle 1.25; then
        banc_dolphin 120 60 780 460
        for surface in bureau demarrer dolphin galerie; do
            banc_surface ui-sombre-125 "$surface" "$barre"
        done
    fi
    if banc_echelle 1.5; then
        banc_dolphin 60 40 720 420
        for surface in bureau demarrer dolphin galerie; do
            banc_surface ui-sombre-150 "$surface" "$barre"
        done
    fi
    banc_essayer "échelle de 100 %" banc_echelle 1
    close_app "$banc_compte" dolphin
    close_app "$banc_compte" plasmawindowed
    log "Banc de l'interface (D-052) : rapport"
    if ! banc_mesurer rapport "$repo/build_files/interface/jetons.toml" "$banc_mesures" "$work/captures/ui-rapport.md"; then
        die "mesures de l'interface hors cible, alors que leur lot est terminé (D-052) : voir ui-rapport.md"
    fi
}
