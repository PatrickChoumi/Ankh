#!/usr/bin/bash
# D-052 : lance une applet d'Ankh dans plasmawindowed (plasma-workspace),
# hors écran, dans un compte vide et une session D-Bus à elle, puis échoue si
# QML écrit un avertissement venant de l'applet ou du module commun d'Ankh.
# C'est le vrai contexte de Plasma : main.qml, ses représentations et leur
# ordre de création, que les sondes (qui créent les fichiers de l'applet
# elles-mêmes) ne voient pas. Le lot 6a est passé au travers : le bouton de la
# barre lisait un id pas encore créé (« Cannot read property 'iconeReseau' of
# undefined »), vu seulement en VM.
#
# Usage : verifier-applet-plasma.sh <Id de l'applet> [dossier des applets (plasmoids)]
set -euo pipefail

ici="$(dirname "$(readlink -f "$0")")"
applet="$1"
applets="$(readlink -f "${2:-${ici}/../files/usr/share/plasma/plasmoids}")"
modules="$(readlink -f "${ici}/../files/usr/lib64/qt6/qml")"
readonly DUREE=12

if [[ ! -f "${applets}/${applet}/metadata.json" ]]; then
    echo "Applet ${applet} : absente de ${applets}" >&2
    exit 1
fi

# Une applet sans volet (fullRepresentation) est toujours dépliée : Plasma
# montre le contenu de sa racine et ne crée jamais sa représentation compacte
# (appletShouldBeExpanded, src/plasmaquick/appletquickitem.cpp de libplasma
# 6.7). Le bouton « Vue des tâches » (lot 7b) est ainsi resté vide en VM, sans
# avertissement : plasmawindowed ne le voit pas.
racine_qml="${applets}/${applet}/contents/ui/main.qml"
if grep -q '^    compactRepresentation:' "${racine_qml}" && ! grep -q '^    fullRepresentation:' "${racine_qml}"; then
    echo "Applet ${applet} : représentation compacte sans volet (fullRepresentation) ; Plasma ne la montrera jamais." >&2
    echo "Mettre le bouton dans la racine, avec preferredRepresentation: fullRepresentation (comme org.ankh.bureau)." >&2
    exit 1
fi

travail="$(mktemp -d)"
trap 'rm -rf "${travail}"' EXIT
install -d -m 0700 "${travail}/run"
mkdir -p "${travail}/maison/.local/share/plasma/plasmoids" "${travail}/maison/.config"
cp -r "${applets}/${applet}" "${travail}/maison/.local/share/plasma/plasmoids/"
journal="${travail}/plasmawindowed.log"

# plasmawindowed ne s'arrête pas seul : timeout l'arrête au bout de DUREE
# secondes et rend alors 124. Un autre code veut dire qu'il a quitté ou
# planté avant (il quitte proprement, code 0, quand on l'arrête : le code de
# timeout seul le distingue).
if env -i PATH=/usr/bin:/usr/sbin HOME="${travail}/maison" XDG_CONFIG_HOME="${travail}/maison/.config" \
    XDG_DATA_HOME="${travail}/maison/.local/share" XDG_CACHE_HOME="${travail}/maison/.cache" \
    XDG_RUNTIME_DIR="${travail}/run" LANG=C.UTF-8 QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
    QT_FORCE_STDERR_LOGGING=1 QML_IMPORT_PATH="${modules}" \
    dbus-run-session -- timeout "${DUREE}" plasmawindowed "${applet}" > "${journal}" 2>&1; then
    code=0
else
    code=$?
fi
if [[ ${code} -ne 124 ]]; then
    cat "${journal}"
    echo "Applet ${applet} : plasmawindowed s'est arrêté seul (code ${code}, lignes ci-dessus)" >&2
    exit 1
fi
# Avertissements QML de l'applet ou du module commun d'Ankh
if grep -E "file://[^ ]*(plasmoids/${applet}/|org/ankh/commun/)[^ ]*\.qml:[0-9]+" "${journal}" > "${travail}/avertissements"; then
    cat "${travail}/avertissements" >&2
    echo "Applet ${applet} : avertissements QML dans plasmawindowed (lignes ci-dessus)" >&2
    exit 1
fi
echo "Applet ${applet} : chargée par plasmawindowed, sans avertissement QML"
