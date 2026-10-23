#!/usr/bin/bash
# D-052, lots 1 à 3 : ce qui se compile depuis ses sources avant l'image,
# dans une étape à part du Containerfile (« outils »), pour que ses outils de
# compilation (fontmake, xcursorgen, rsvg-convert, cmake, g++ et les en-têtes
# de KDE) n'entrent pas dans l'image :
# - la police Selawik, de Microsoft (OFL 1.1, https://github.com/microsoft/Selawik),
#   compilée depuis ses sources UFO ;
# - les curseurs « Ankh-curseurs » : les curseurs Fluent blancs
#   (GPL-3.0, dossier cursors de https://github.com/vinceliuice/Fluent-icon-theme,
#   ceux qu'AnduinOS installe sous le nom « Fluent-dark-cursors »), dont le bleu
#   d'accent, celui de l'anneau d'attente, devient le violet d'Ankh ;
# - la décoration des fenêtres d'Ankh (lot 2), dérivée de celle de Breeze,
#   dont les sources sont dans le dépôt d'Ankh (build_files/decoration) ;
# - le style des contrôles d'Ankh (lot 3), dérivé de celui de Breeze, dont
#   les sources sont dans le dépôt d'Ankh (build_files/style) ;
# - le thème GTK Fluent (lot 3, mon choix du 2026-10-15, confirmé le
#   2026-10-21), au violet d'Ankh (GPL-3.0,
#   https://github.com/vinceliuice/Fluent-gtk-theme, celui d'AnduinOS).
# Avant tout, le Démarrer d'Ankh (lot 5), paquet QML dérivé de Kickoff, est
# vérifié sur le Plasma de cette image de base (build_files/plasma/verifier-demarrer.sh :
# version de Plasma, qmllint, sonde hors écran) ; rien n'en sort dans /sortie.
# Les paramètres rapides d'Ankh (lot 6a) le sont de même
# (build_files/plasma/verifier-reglages.sh). Puis chaque applet d'Ankh est
# lancée dans plasmawindowed, le vrai contexte de Plasma, sans avertissement
# QML permis (build_files/plasma/verifier-applet-plasma.sh). Alt+Tab d'Ankh
# (lot 7a) est vérifié par build_files/plasma/verifier-alttab.sh, la vue des
# tâches d'Ankh (lot 7b) par build_files/plasma/verifier-vuetaches.sh, l'écran
# de verrouillage d'Ankh (lot 7c) par build_files/plasma/verifier-verrouillage.sh
# (kscreenlocker_greet en mode test), son écran de déconnexion par
# build_files/plasma/verifier-deconnexion.sh (ksmserver-logout-greeter).
# Chaque source est prise à un commit figé, vérifié après le téléchargement.
# Résultat dans le dossier donné (par défaut /sortie), copié dans l'image par
# build.sh : polices/selawik, icones/Ankh-curseurs, decoration, style et themes.
set -euo pipefail

sortie=${1:-/sortie}
travail="$(mktemp -d)"
trap 'rm -rf "${travail}"' EXIT

readonly SELAWIK_DEPOT=https://github.com/microsoft/Selawik
readonly SELAWIK_COMMIT=89362e84731d1f5777fa078fd4d5ebbd339e4378 # 2023-06-05, version 1.01 des sources
readonly FLUENT_DEPOT=https://github.com/vinceliuice/Fluent-icon-theme
readonly FLUENT_COMMIT=c8a244f571ef8fb47812bdc9dbce76546cedce69 # 2026-08-31
readonly FLUENT_GTK_DEPOT=https://github.com/vinceliuice/Fluent-gtk-theme
readonly FLUENT_GTK_COMMIT=7a49a464b0188c340101c52965c18190b1c694cf # 2026-08-18
# Violets du thème « purple » de Fluent (Material) -> violets d'Ankh : accent
# en clair (#7c3aed) et en sombre (#a78bfa, D-037), et les deux teintes des
# liens visités, de la même famille (#6d28d9 et #c4b5fd)
readonly VIOLETS_GTK=('AB47BC:7C3AED' 'BA68C8:A78BFA' '9C27B0:6D28D9' 'CE93D8:C4B5FD')
# Bleu d'accent des curseurs Fluent (#0078d4, celui de Windows, et son reflet
# #23e6fa) -> violet d'Ankh (sélection #8455f0 et violet du logo #a78bfa, D-037)
readonly COULEURS=('0078d4:8455f0' '23e6fa:a78bfa')
# Tailles de chaque curseur, comme build.sh des curseurs Fluent : 24 (dessin
# de 32 px), 30, 36 et 48
readonly TAILLES=('x1:32' 'x1_25:40' 'x1_5:48' 'x2:64')

# Récupère un dépôt à un commit, seulement les dossiers demandés
recuperer() { # $1 : dépôt, $2 : commit, $3 : dossier de travail, puis les dossiers voulus
    local depot=$1 commit=$2 dossier=$3
    shift 3
    git init -q "${dossier}"
    git -C "${dossier}" remote add origin "${depot}"
    git -C "${dossier}" sparse-checkout set "$@"
    git -C "${dossier}" fetch -q --depth 1 --filter=blob:none origin "${commit}"
    git -C "${dossier}" checkout -q FETCH_HEAD
    if [[ "$(git -C "${dossier}" rev-parse HEAD)" != "${commit}" ]]; then
        echo "${depot} : commit inattendu $(git -C "${dossier}" rev-parse HEAD)" >&2
        exit 1
    fi
    echo "${depot} : ${commit}"
}

echo "== Démarrer d'Ankh : vérifications"
"$(dirname "$(readlink -f "$0")")/plasma/verifier-demarrer.sh"
echo "== Paramètres rapides d'Ankh : vérifications"
"$(dirname "$(readlink -f "$0")")/plasma/verifier-reglages.sh"
echo "== Alt+Tab d'Ankh : vérifications"
"$(dirname "$(readlink -f "$0")")/plasma/verifier-alttab.sh"
echo "== Vue des tâches d'Ankh : vérifications"
"$(dirname "$(readlink -f "$0")")/plasma/verifier-vuetaches.sh"
echo "== Écran de verrouillage d'Ankh : vérifications"
"$(dirname "$(readlink -f "$0")")/plasma/verifier-verrouillage.sh"
echo "== Écran de déconnexion d'Ankh : vérifications"
"$(dirname "$(readlink -f "$0")")/plasma/verifier-deconnexion.sh"
echo "== Applets d'Ankh dans plasmawindowed"
for applet in org.ankh.bureau org.ankh.demarrer org.ankh.reglages org.ankh.horloge; do
    "$(dirname "$(readlink -f "$0")")/plasma/verifier-applet-plasma.sh" "${applet}"
done

echo "== Police Selawik"
recuperer "${SELAWIK_DEPOT}" "${SELAWIK_COMMIT}" "${travail}/selawik" "Source files/UFO"
polices="${sortie}/polices/selawik"
install -d -m 0755 "${polices}"
# Dates des fichiers de police : celle du commit, pour que la compilation
# donne toujours les mêmes fichiers (SOURCE_DATE_EPOCH, lu par ufo2ft)
SOURCE_DATE_EPOCH="$(git -C "${travail}/selawik" log -1 --format=%ct)"
export SOURCE_DATE_EPOCH
for graisse in Light Regular Bold; do
    fontmake -u "${travail}/selawik/Source files/UFO/Selawik-${graisse}.ufo" -o ttf --output-dir "${polices}"
done
install -m 0644 "${travail}/selawik/LICENSE.txt" "${polices}/OFL.txt"
ls -l "${polices}"

echo "== Curseurs Ankh-curseurs"
recuperer "${FLUENT_DEPOT}" "${FLUENT_COMMIT}" "${travail}/fluent" cursors
source_curseurs="${travail}/fluent/cursors/src"
dessins="${travail}/dessins"
cp -r "${source_curseurs}/svg-white" "${dessins}"
for couple in "${COULEURS[@]}"; do
    avant="${couple%%:*}"
    apres="${couple##*:}"
    # La couleur doit encore exister dans les sources : sinon, leur dessin a
    # changé et le violet d'Ankh ne serait pas appliqué.
    if ! grep -qil "#${avant}" "${dessins}"/*.svg; then
        echo "Curseurs Fluent : la couleur #${avant} n'existe plus dans les sources" >&2
        exit 1
    fi
    sed -i "s/#${avant}/#${apres}/gI" "${dessins}"/*.svg
done
if grep -qil '#0078d4\|#23e6fa' "${dessins}"/*.svg; then
    echo "Curseurs Fluent : du bleu reste après la recoloration" >&2
    exit 1
fi
images="${travail}/images"
for taille in "${TAILLES[@]}"; do
    install -d "${images}/${taille%%:*}"
    for dessin in "${dessins}"/*.svg; do
        rsvg-convert -w "${taille##*:}" -h "${taille##*:}" -o "${images}/${taille%%:*}/$(basename "${dessin}" .svg).png" "${dessin}"
    done
done
theme="${sortie}/icones/Ankh-curseurs"
install -d -m 0755 "${theme}/cursors"
for config in "${source_curseurs}"/config/*.cursor; do
    xcursorgen -p "${images}" "${config}" "${theme}/cursors/$(basename "${config}" .cursor)"
done
# Autres noms des mêmes curseurs (cursorList : « nom cible »)
while read -r nom cible; do
    if [[ -n "${nom}" && ! -e "${theme}/cursors/${nom}" ]]; then
        ln -s "${cible}" "${theme}/cursors/${nom}"
    fi
done < "${source_curseurs}/cursorList"
# Tout lien doit mener à un curseur
for lien in "${theme}"/cursors/*; do
    if [[ ! -e "${lien}" ]]; then
        echo "Curseur sans cible : ${lien}" >&2
        exit 1
    fi
done
cat > "${theme}/index.theme" << 'THEME'
[Icon Theme]
Name=Ankh-curseurs
Comment=Curseurs blancs d'Ankh : curseurs Fluent, au violet d'Ankh (D-052)
Inherits=breeze_cursors
THEME
install -m 0644 "${travail}/fluent/cursors/LICENSE" "${theme}/LICENSE"
echo "$(find "${theme}/cursors" -type f | wc -l) curseurs, $(find "${theme}/cursors" -type l | wc -l) autres noms"

echo "== Décoration des fenêtres d'Ankh"
sources="$(dirname "$(readlink -f "$0")")/decoration"
cmake -S "${sources}" -B "${travail}/decoration" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build "${travail}/decoration" -j "$(nproc)"
install -d -m 0755 "${sortie}/decoration"
install -m 0755 "${travail}/decoration/bin/org.ankh.decoration.so" "${sortie}/decoration/"
echo "Compilée avec kdecoration $(rpm -q --qf '%{VERSION}-%{RELEASE}' kdecoration-devel) : $(ls -l "${sortie}/decoration")"

echo "== Style des contrôles d'Ankh"
sources="$(dirname "$(readlink -f "$0")")/style"
cmake -S "${sources}" -B "${travail}/style" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build "${travail}/style" -j "$(nproc)"
install -d -m 0755 "${sortie}/style"
install -m 0755 "${travail}/style/bin/ankh6.so" "${sortie}/style/"
install -m 0644 "${sources}/ankh.themerc" "${sortie}/style/"
echo "Compilé avec Qt $(rpm -q --qf '%{VERSION}-%{RELEASE}' qt6-qtbase-devel) et frameworkintegration $(rpm -q --qf '%{VERSION}-%{RELEASE}' kf6-frameworkintegration-devel) : $(ls -l "${sortie}/style")"

echo "== Thème GTK Fluent, au violet d'Ankh"
recuperer "${FLUENT_GTK_DEPOT}" "${FLUENT_GTK_COMMIT}" "${travail}/fluent-gtk" src
fluent_gtk="${travail}/fluent-gtk"
# Fichiers du violet : la palette des feuilles de style, et les dessins des
# cases, boutons radio et curseurs de GTK 3 et 4 (assets-purple.svg) et de
# GTK 2 (gtkrc et assets-folder)
fichiers_violets=(
    "${fluent_gtk}/src/_sass/_color-palette.scss"
    "${fluent_gtk}/src/gtk/assets-purple.svg"
    "${fluent_gtk}/src/gtk-2.0/gtkrc-purple"
    "${fluent_gtk}/src/gtk-2.0/gtkrc-purple-Dark"
    "${fluent_gtk}/src/gtk-2.0/assets-folder/assets-purple.svg"
    "${fluent_gtk}/src/gtk-2.0/assets-folder/assets-purple-Dark.svg"
)
for couple in "${VIOLETS_GTK[@]}"; do
    avant="${couple%%:*}"
    apres="${couple##*:}"
    # Chaque violet doit encore exister dans les sources : sinon, leur dessin
    # a changé et le violet d'Ankh ne serait pas appliqué partout.
    if ! grep -qi "#${avant}" "${fichiers_violets[@]}"; then
        echo "Fluent GTK : #${avant} introuvable dans ses sources" >&2
        exit 1
    fi
    sed -i "s/#${avant}/#${apres}/Ig" "${fichiers_violets[@]}"
done
# Images des contrôles, redessinées depuis les dessins recolorés, à 1× et 2×,
# comme render-assets.sh de Fluent (rsvg-convert au lieu d'Inkscape)
redessiner() { # $1 : dossier des images, $2 : dessin, $3 : liste des images
    rm -rf "$1"
    mkdir -p "$1"
    while read -r image; do
        [[ -n "${image}" ]] || continue
        rsvg-convert --export-id="${image}" -o "$1/${image}.png" "$2"
        rsvg-convert --export-id="${image}" --zoom=2 -o "$1/${image}@2.png" "$2"
    done < "$3"
}
redessiner "${fluent_gtk}/src/gtk/assets-purple" "${fluent_gtk}/src/gtk/assets-purple.svg" "${fluent_gtk}/src/gtk/assets.txt"
for variante in assets-purple assets-purple-Dark; do
    redessiner "${fluent_gtk}/src/gtk-2.0/assets-folder/${variante}" "${fluent_gtk}/src/gtk-2.0/assets-folder/${variante}.svg" \
        "${fluent_gtk}/src/gtk-2.0/assets-folder/assets.txt"
done
# Variante d'AnduinOS : fenêtres arrondies, sans bord (« round noborder »),
# taille normale. Un seul thème, « Fluent-Ankh » : la variante claire, dont
# la feuille sombre (gtk-dark.css) est celle de la variante sombre, octet
# pour octet (vérifié le 2026-10-21). GTK prend la feuille sombre quand KDE
# demande le sombre (gtk-application-prefer-dark-theme, écrit à chaque
# session par kded/gtkconfig.cpp de kde-gtk-config) : le thème suit le clair
# et le sombre d'Ankh.
themes="${travail}/themes"
mkdir -p "${themes}"
(cd "${fluent_gtk}" && ./install.sh --dest "${themes}" --name Fluent --theme purple --color light --size standard --tweaks round noborder)
theme="${sortie}/themes/Fluent-Ankh"
install -d -m 0755 "${theme}"
# Seulement ce qui sert à KDE : GTK 2, 3 et 4 (pas GNOME Shell, Cinnamon…)
cp -r "${themes}/Fluent-round-purple-Light/"{gtk-2.0,gtk-3.0,gtk-4.0} "${theme}/"
install -m 0644 "${fluent_gtk}/COPYING" "${theme}/COPYING"
cat > "${theme}/index.theme" << 'THEME'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Fluent-Ankh
Comment=Thème GTK Fluent (vinceliuice/Fluent-gtk-theme, GPL-3.0), au violet d'Ankh (D-052)
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=Fluent-Ankh
THEME
# Plus aucun violet de Fluent, sauf dans la palette nommée que GTK propose
# aux applications (« @define-color GRAPE_500 #9C27B0 »…), qui n'est pas
# l'accent du thème
for couple in "${VIOLETS_GTK[@]}"; do
    if grep -rhi "#${couple%%:*}" "${theme}" | grep -vE '^@define-color [A-Z0-9_]+ #' > /dev/null; then
        echo "Fluent-Ankh : le violet #${couple%%:*} de Fluent est resté" >&2
        exit 1
    fi
done
for feuille in gtk-3.0/gtk.css gtk-3.0/gtk-dark.css gtk-4.0/gtk.css gtk-4.0/gtk-dark.css; do
    echo "Fluent-Ankh, ${feuille} : $(grep -o -i '#7c3aed\|#a78bfa' "${theme}/${feuille}" | sort | uniq -c | tr '\n' ' ')"
done
