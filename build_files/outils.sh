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
#   les sources sont dans le dépôt d'Ankh (build_files/style).
# Chaque source est prise à un commit figé, vérifié après le téléchargement.
# Résultat dans le dossier donné (par défaut /sortie), copié dans l'image par
# build.sh : polices/selawik, icones/Ankh-curseurs, decoration et style.
set -euo pipefail

sortie=${1:-/sortie}
travail="$(mktemp -d)"
trap 'rm -rf "${travail}"' EXIT

readonly SELAWIK_DEPOT=https://github.com/microsoft/Selawik
readonly SELAWIK_COMMIT=89362e84731d1f5777fa078fd4d5ebbd339e4378 # 2023-06-05, version 1.01 des sources
readonly FLUENT_DEPOT=https://github.com/vinceliuice/Fluent-icon-theme
readonly FLUENT_COMMIT=c8a244f571ef8fb47812bdc9dbce76546cedce69 # 2026-08-31
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
