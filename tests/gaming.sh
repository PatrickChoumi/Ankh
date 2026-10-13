#!/usr/bin/bash
# D-041, D-050, D-051 : option Gaming. Outils du jeu dans le système, ntsync,
# entrées du menu des huit applications (préparées au premier clic), session
# « Ankh Console ».
# Lancé dans l'image par « just test » (Test 16), en root, dans un conteneur
# jetable et sans réseau : rien n'est téléchargé, et ce qu'il écrit dans /etc
# et /usr/local disparaît avec lui.
set -euo pipefail

echec() {
    echo "ÉCHEC : $*" >&2
    exit 1
}

entrees=/usr/share/ankh/options/gaming/applications
session=/usr/share/ankh/options/gaming/wayland-sessions/ankh-console.desktop
applications=(com.valvesoftware.Steam com.heroicgameslauncher.hgl net.lutris.Lutris
    com.usebottles.bottles com.vysp3r.ProtonPlus com.github.Matoking.protontricks
    com.discordapp.Discord com.obsproject.Studio)

echo "Outils du jeu dans le système"
rpm -q gamemode mangohud gamescope vkBasalt steam-devices
[[ -n "$(rpm -ql steam-devices | grep '/udev/rules.d/')" ]] || echec "règles des manettes de Steam absentes"
command -v mangoapp gamescope gamemoded kwin_wayland flatpak konsole > /dev/null || echec "outil du jeu ou de la session absent"
# Les couches Vulkan restent à l'arrêt sans leur variable
for couche in /usr/share/vulkan/implicit_layer.d/MangoHud*.json /usr/share/vulkan/implicit_layer.d/vkBasalt*.json; do
    grep -q '"enable_environment"' "${couche}" || echec "${couche} s'active sans variable"
done

# D-051 : ntsync, chargé par ankh-options avec l'option Gaming (au démarrage
# et à chaque choix ; pas ici, dans un conteneur sans noyau à lui). Il doit
# être dans le noyau de l'image (kernel-modules-core de Fedora).
noyaux=(/usr/lib/modules/*/)
[[ ${#noyaux[@]} -eq 1 ]] || echec "un seul noyau attendu dans l'image : ${noyaux[*]}"
modinfo -k "$(basename "${noyaux[0]}")" ntsync > /dev/null || echec "module ntsync absent du noyau de l'image (D-051)"

echo "Entrées du menu de l'option Gaming"
test -x /usr/libexec/ankh-flatpak || echec "/usr/libexec/ankh-flatpak absent"
desktop-file-validate "${entrees}"/*.desktop
[[ "$(find "${entrees}" -name '*.desktop' | wc -l)" -eq "${#applications[@]}" ]] || echec "nombre d'entrées inattendu"
for application in "${applications[@]}"; do
    entree="${entrees}/${application}.desktop"
    test -f "${entree}" || echec "${application} : entrée absente"
    grep -qx "Exec=/usr/libexec/ankh-flatpak ${application}" "${entree}" || echec "${application} : ne passe pas par ankh-flatpak"
    grep -qx "Icon=${application}" "${entree}" || echec "${application} : icône inattendue"
    compgen -G "/usr/share/icons/hicolor/*/apps/${application}.png" > /dev/null || echec "${application} : icône absente du thème"
    grep -aq "${application}" /usr/share/icons/hicolor/icon-theme.cache || echec "${application} : icône absente du cache"
    grep -q "${application}" /usr/libexec/ankh-flatpak || echec "${application} : inconnue de ankh-flatpak"
done
# Rien n'est installé dans l'image, et une application inconnue est refusée
[[ -z "$(/usr/libexec/ankh-flatpak installees)" ]] || echec "des applications Gaming sont déjà installées dans l'image"
for mauvais in "" "org.exemple.Inconnue" "com.valvesoftware.Steam;id"; do
    if /usr/libexec/ankh-flatpak preparer "${mauvais}" 2> /dev/null; then
        echec "ankh-flatpak accepte à tort « ${mauvais} »"
    fi
done

echo "Session « Ankh Console »"
test -x /usr/libexec/ankh-console || echec "/usr/libexec/ankh-console absent"
test -f "${session}" || echec "session « Ankh Console » absente"
grep -qx "Name=Ankh Console" "${session}" || echec "session : nom inattendu"
grep -qx "Exec=/usr/libexec/ankh-console" "${session}" || echec "session : commande inattendue"
test ! -e /usr/share/wayland-sessions/ankh-console.desktop || echec "la session est visible sans l'option Gaming"

echo "Avec Gaming, les entrées et la session apparaissent ; sans, elles partent"
/usr/libexec/ankh-options appliquer gaming
for application in "${applications[@]}"; do
    [[ "$(readlink "/usr/local/share/applications/${application}.desktop")" == "${entrees}/${application}.desktop" ]] ||
        echec "${application} absent du menu avec Gaming"
done
[[ "$(readlink /usr/local/share/wayland-sessions/ankh-console.desktop)" == "${session}" ]] || echec "session absente avec Gaming"
test ! -e /usr/local/share/applications/ankh-vscode.desktop || echec "VS Code présent avec Gaming seule"
/usr/libexec/ankh-options appliquer dev
for application in "${applications[@]}"; do
    test ! -e "/usr/local/share/applications/${application}.desktop" || echec "${application} reste dans le menu sans Gaming"
done
test ! -e /usr/local/share/wayland-sessions/ankh-console.desktop || echec "la session reste sans Gaming"

echo "Option Gaming : tout est en place."
