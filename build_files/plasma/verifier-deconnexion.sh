#!/usr/bin/bash
# D-052, lot 7c : vérifie l'écran de déconnexion d'Ankh à la construction,
# dans l'étape « outils » du Containerfile, sur le Plasma de la même image de
# base. L'écran de déconnexion est celui du thème global (contents/logout),
# adapté par adapter-deconnexion.py, avec le bouton d'Ankh
# (deconnexion/LogoutButton.qml). Une erreur QML y laisserait la session sans
# écran pour éteindre ou se déconnecter. La construction échoue donc :
# 1. si adapter-deconnexion.py ne trouve plus le texte qu'il remplace (KDE l'a
#    changé) ;
# 2. si l'écran de déconnexion de KDE (ksmserver-logout-greeter --windowed,
#    hors écran, dans un compte vide et une session D-Bus à lui), chargé avec
#    le thème adapté, quitte avant 12 s, ou si QML écrit un avertissement
#    venant de l'écran de déconnexion.
#
# Usage : verifier-deconnexion.sh
set -euo pipefail

ici="$(dirname "$(readlink -f "$0")")"
readonly THEME=org.fedoraproject.fedoradark.desktop
readonly DUREE=12

travail="$(mktemp -d)"
trap 'rm -rf "${travail}"' EXIT
install -d -m 0700 "${travail}/run"
mkdir -p "${travail}/maison/.local/share/plasma/look-and-feel" "${travail}/maison/.config"
copie="${travail}/maison/.local/share/plasma/look-and-feel/${THEME}"
cp -r "/usr/share/plasma/look-and-feel/${THEME}" "${copie}"

# 1. L'adaptation, sur une copie du thème, comme build.sh dans l'image
python3 "${ici}/adapter-deconnexion.py" "${copie}/contents/logout/Logout.qml"
install -m 0644 "${ici}/deconnexion/LogoutButton.qml" "${copie}/contents/logout/LogoutButton.qml"
grep -q '#0d1117' "${copie}/contents/logout/Logout.qml"

# 2. L'écran de déconnexion, avec la copie adaptée (KPackage la préfère à
# celle du système, car elle est dans le compte)
journal="${travail}/deconnexion.log"
if env -i PATH=/usr/bin:/usr/sbin HOME="${travail}/maison" XDG_CONFIG_HOME="${travail}/maison/.config" \
    XDG_DATA_HOME="${travail}/maison/.local/share" XDG_CACHE_HOME="${travail}/maison/.cache" \
    XDG_RUNTIME_DIR="${travail}/run" LANG=C.UTF-8 QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
    QT_FORCE_STDERR_LOGGING=1 \
    dbus-run-session -- timeout "${DUREE}" /usr/libexec/ksmserver-logout-greeter --windowed --lookandfeel "${THEME}" \
    > "${journal}" 2>&1; then
    code=0
else
    code=$?
fi
if [[ ${code} -ne 124 ]]; then
    cat "${journal}"
    echo "Écran de déconnexion d'Ankh : ksmserver-logout-greeter s'est arrêté seul (code ${code}, lignes ci-dessus)" >&2
    exit 1
fi
if grep -E "(file://[^ ]*/look-and-feel/${THEME//./\\.}/contents/logout/[^ ]*\.qml:[0-9]+|Trying default theme|Couldn't find a theme)" \
    "${journal}" > "${travail}/avertissements"; then
    cat "${travail}/avertissements" >&2
    echo "Écran de déconnexion d'Ankh : avertissements QML (lignes ci-dessus)" >&2
    exit 1
fi
echo "Écran de déconnexion d'Ankh : adapté et chargé par ksmserver-logout-greeter, sans avertissement QML"
