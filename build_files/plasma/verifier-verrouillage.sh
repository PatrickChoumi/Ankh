#!/usr/bin/bash
# D-052, lot 7c : vérifie l'écran de verrouillage d'Ankh à la construction,
# dans l'étape « outils » du Containerfile, sur le Plasma de la même image de
# base. L'écran de verrouillage est celui de la coque de Plasma
# (contents/lockscreen de org.kde.plasma.desktop), adapté par
# adapter-plasma.py avec l'horloge d'Ankh (HorlogeAnkh.qml). Une erreur QML y
# serait grave : un écran de verrouillage qui s'affiche mal. La construction
# échoue donc :
# 1. si adapter-plasma.py ne trouve plus le texte qu'il remplace (KDE l'a
#    changé) ;
# 2. si l'écran de verrouillage de kscreenlocker (kscreenlocker_greet, en mode
#    test, hors écran, dans un compte vide et une session D-Bus à lui) quitte
#    avant 12 s, ou si QML écrit un avertissement venant de l'écran de
#    verrouillage.
# L'authentification elle-même n'est pas touchée par l'adaptation : seul le
# dessin change.
#
# Usage : verifier-verrouillage.sh
set -euo pipefail

ici="$(dirname "$(readlink -f "$0")")"
fichiers="$(readlink -f "${ici}/../files")"
readonly COQUE=/usr/share/plasma/shells/org.kde.plasma.desktop
readonly DUREE=12

travail="$(mktemp -d)"
trap 'rm -rf "${travail}"' EXIT
install -d -m 0700 "${travail}/run"
mkdir -p "${travail}/maison/.local/share/plasma/shells" "${travail}/maison/.config"
copie="${travail}/maison/.local/share/plasma/shells/org.kde.plasma.desktop"
cp -r "${COQUE}" "${copie}"

# 1. L'adaptation, sur une copie de la coque, comme build.sh dans l'image
python3 "${ici}/adapter-plasma.py" "${copie}"
install -m 0644 "${fichiers}${COQUE}/contents/lockscreen/HorlogeAnkh.qml" "${copie}/contents/lockscreen/"
grep -q 'HorlogeAnkh {' "${copie}/contents/lockscreen/LockScreenUi.qml"

# 2. L'écran de verrouillage, dans la copie adaptée (KPackage la préfère à
# celle du système, car elle est dans le compte)
journal="${travail}/greet.log"
if env -i PATH=/usr/bin:/usr/sbin HOME="${travail}/maison" XDG_CONFIG_HOME="${travail}/maison/.config" \
    XDG_DATA_HOME="${travail}/maison/.local/share" XDG_CACHE_HOME="${travail}/maison/.cache" \
    XDG_RUNTIME_DIR="${travail}/run" LANG=C.UTF-8 QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
    QT_FORCE_STDERR_LOGGING=1 \
    dbus-run-session -- timeout "${DUREE}" /usr/libexec/kscreenlocker_greet --testing > "${journal}" 2>&1; then
    code=0
else
    code=$?
fi
if [[ ${code} -ne 124 ]]; then
    cat "${journal}"
    echo "Écran de verrouillage d'Ankh : kscreenlocker_greet s'est arrêté seul (code ${code}, lignes ci-dessus)" >&2
    exit 1
fi
if grep -E 'file://[^ ]*/shells/org\.kde\.plasma\.desktop/contents/lockscreen/[^ ]*\.qml:[0-9]+' "${journal}" \
    > "${travail}/avertissements"; then
    cat "${travail}/avertissements" >&2
    echo "Écran de verrouillage d'Ankh : avertissements QML (lignes ci-dessus)" >&2
    exit 1
fi
if ! grep -q 'Locked at' "${journal}"; then
    cat "${journal}"
    echo "Écran de verrouillage d'Ankh : kscreenlocker_greet n'a pas verrouillé (« Locked at » absent)" >&2
    exit 1
fi
echo "Écran de verrouillage d'Ankh : adapté et chargé par kscreenlocker_greet, sans avertissement QML"
