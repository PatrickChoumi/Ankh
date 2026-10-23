#!/usr/bin/bash
# D-052, lot 6 : vérifications des volets de la barre d'Ankh à la
# construction, dans l'étape « outils » du Containerfile, qui part de la même
# image de base que l'image d'Ankh, donc du même Plasma : les paramètres
# rapides (org.ankh.reglages, lot 6a) et l'horloge, avec ses notifications et
# son calendrier (org.ankh.horloge, lot 6b). Ces applets se servent des
# modules QML de plasma-nm, plasma-pa, bluedevil, powerdevil et
# plasma-workspace, dont plusieurs sont privés et sans promesse de
# stabilité ; une erreur QML ne fait pas tomber Plasma : un volet
# s'afficherait à moitié sans que rien n'échoue. La construction échoue
# donc, comme pour le Démarrer (verifier-demarrer.sh) :
# 1. si ces paquets ne sont plus en version 6.7.5 : leurs changements sont à
#    reporter d'abord (règle de D-052) ;
# 2. si qmllint trouve un module, un type ou un import introuvable ;
# 3. si une sonde échoue ou écrit un avertissement QML : reglages-sonde.qml
#    crée hors écran le vrai état, le bouton et le volet avec chacune de ses
#    pages ; horloge-sonde.qml crée l'horloge et son volet, et vérifie les
#    rôles, énumérations et fonctions des notifications et du calendrier.
#
# Usage : verifier-reglages.sh [dossier des applets (plasmoids)]
set -euo pipefail

ici="$(dirname "$(readlink -f "$0")")"
applets="$(readlink -f "${1:-${ici}/../files/usr/share/plasma/plasmoids}")"
# Module QML commun d'Ankh (org.ankh.commun : couleurs, flèche, boutons,
# interrupteur, curseur), installé avec l'image dans /usr/lib64/qt6/qml
modules="$(readlink -f "${ici}/../files/usr/lib64/qt6/qml")"
readonly PLASMA_ATTENDU=6.7.5
readonly QT_BIN=/usr/lib64/qt6/bin

# 1. Version des paquets de Plasma dont les applets se servent
for rpm_plasma in plasma-nm plasma-pa bluedevil powerdevil plasma-workspace; do
    version="$(rpm -q --qf '%{VERSION}' "${rpm_plasma}")"
    if [[ "${version}" != "${PLASMA_ATTENDU}" ]]; then
        echo "Volets de la barre d'Ankh : ${rpm_plasma} est en version ${version}, et non ${PLASMA_ATTENDU}." >&2
        echo "Les applets org.ankh.reglages et org.ankh.horloge (build_files/files/usr/share/plasma/plasmoids) se servent" >&2
        echo "de ses modules QML et reprennent la logique de ses applets. Reportez-y d'abord les changements de ${PLASMA_ATTENDU} à ${version}" >&2
        echo "(https://invent.kde.org/plasma/${rpm_plasma}), vérifiez-le en VM, puis changez PLASMA_ATTENDU" >&2
        echo "dans build_files/plasma/verifier-reglages.sh (D-052, lot 6)." >&2
        exit 1
    fi
    echo "${rpm_plasma} ${version} : version attendue"
done

travail="$(mktemp -d)"
trap 'rm -rf "${travail}"' EXIT

# Vérifie une applet : son Id, qmllint, puis sa sonde hors écran
# (verifier_applet <Id> <sonde> <nom pour les messages> [fichier exclu de qmllint])
verifier_applet() {
    local id="$1" sonde="$2" nom="$3" exclu="${4:-}"
    local paquet="${applets}/${id}"
    echo "${nom} : paquet ${paquet}"

    python3 -I - "${paquet}/metadata.json" "${id}" << 'PYTHON'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    meta = json.load(f)
if meta["KPlugin"]["Id"] != sys.argv[2]:
    sys.exit(f"{sys.argv[2]} : Id « {meta['KPlugin']['Id']} » dans metadata.json")
PYTHON

    # 2. qmllint : modules, types et imports, avec le module commun d'Ankh
    local fichiers filtre=()
    if [[ -n "${exclu}" ]]; then
        filtre=(! -name "${exclu}")
    fi
    mapfile -t fichiers < <(find "${paquet}/contents/ui" "${modules}/org/ankh/commun" -maxdepth 1 -name '*.qml' \
        "${filtre[@]}" | sort)
    if [[ ${#fichiers[@]} -eq 0 ]]; then
        echo "${nom} : aucun fichier QML dans ${paquet}/contents/ui" >&2
        exit 1
    fi
    if ! "${QT_BIN}/qmllint" -I "${modules}" -I /usr/lib64/qt6/qml --unqualified disable --missing-property disable \
        --unused-imports disable --import error --missing-type error --unresolved-type error "${fichiers[@]}"; then
        echo "${nom} : qmllint a trouvé un module, un type ou un import introuvable (lignes ci-dessus)" >&2
        exit 1
    fi
    echo "qmllint : ${#fichiers[@]} fichiers sans erreur d'import ni de type"

    # 3. Sonde hors écran, dans un compte vide et sans session
    local dossier="${travail}/${id}"
    mkdir "${dossier}"
    cp -r "${paquet}" "${dossier}/paquet"
    cp "${ici}/${sonde}" "${dossier}/sonde.qml"
    install -d -m 0700 "${dossier}/run" "${dossier}/maison"
    local journal="${dossier}/sonde.log" code
    if env HOME="${dossier}/maison" XDG_RUNTIME_DIR="${dossier}/run" XDG_CONFIG_HOME="${dossier}/maison/.config" \
        XDG_CACHE_HOME="${dossier}/maison/.cache" XDG_DATA_HOME="${dossier}/maison/.local/share" \
        LANG=C.UTF-8 QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_FORCE_STDERR_LOGGING=1 \
        QML_IMPORT_PATH="${modules}" timeout 120 "${QT_BIN}/qml" "${dossier}/sonde.qml" > "${journal}" 2>&1; then
        code=0
    else
        code=$?
    fi
    cat "${journal}"
    if [[ ${code} -ne 0 ]]; then
        echo "${nom} : la sonde a échoué (code ${code}, lignes ci-dessus)" >&2
        exit 1
    fi
    if grep -E 'file://[^ ]*\.qml:[0-9]+' "${journal}" > /dev/null; then
        echo "${nom} : avertissements QML pendant la sonde :" >&2
        grep -E 'file://[^ ]*\.qml:[0-9]+' "${journal}" >&2
        exit 1
    fi
    if ! grep -qE '^(qml: )?SONDE OK' "${journal}"; then
        echo "${nom} : la sonde n'a pas conclu (SONDE OK absent)" >&2
        exit 1
    fi
    echo "${nom} : vérifié"
}

# Son.qml est laissé de côté par qmllint : plasma-pa enregistre ses types
# dans son code, sans fichier de description, et qmllint ne les voit pas ; la
# sonde le crée avec les vrais types.
verifier_applet org.ankh.reglages reglages-sonde.qml "Paramètres rapides d'Ankh" Son.qml
verifier_applet org.ankh.horloge horloge-sonde.qml "Horloge d'Ankh"
