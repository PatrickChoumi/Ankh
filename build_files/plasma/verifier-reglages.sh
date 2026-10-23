#!/usr/bin/bash
# D-052, lot 6a : vérifications des paramètres rapides d'Ankh
# (org.ankh.reglages) à la construction, dans l'étape « outils » du
# Containerfile, qui part de la même image de base que l'image d'Ankh, donc
# du même Plasma. L'applet se sert des modules QML de plasma-nm, plasma-pa,
# bluedevil, powerdevil et plasma-workspace, dont plusieurs sont privés et
# sans promesse de stabilité ; une erreur QML ne fait pas tomber Plasma : le
# volet s'afficherait à moitié sans que rien n'échoue. La construction
# échoue donc, comme pour le Démarrer (verifier-demarrer.sh) :
# 1. si ces paquets ne sont plus en version 6.7.5 : leurs changements sont à
#    reporter d'abord (règle de D-052) ;
# 2. si qmllint trouve un module, un type ou un import introuvable ;
# 3. si la sonde (reglages-sonde.qml), qui crée hors écran le vrai état, le
#    bouton et le volet avec chacune de ses pages, échoue ou écrit un
#    avertissement QML.
#
# Usage : verifier-reglages.sh [dossier du paquet org.ankh.reglages]
set -euo pipefail

ici="$(dirname "$(readlink -f "$0")")"
paquet="$(readlink -f "${1:-${ici}/../files/usr/share/plasma/plasmoids/org.ankh.reglages}")"
readonly PLASMA_ATTENDU=6.7.5
readonly QT_BIN=/usr/lib64/qt6/bin

echo "Paramètres rapides d'Ankh : paquet ${paquet}"

# 1. Version des paquets de Plasma dont l'applet se sert
for rpm_plasma in plasma-nm plasma-pa bluedevil powerdevil plasma-workspace; do
    version="$(rpm -q --qf '%{VERSION}' "${rpm_plasma}")"
    if [[ "${version}" != "${PLASMA_ATTENDU}" ]]; then
        echo "Paramètres rapides d'Ankh : ${rpm_plasma} est en version ${version}, et non ${PLASMA_ATTENDU}." >&2
        echo "L'applet (build_files/files/usr/share/plasma/plasmoids/org.ankh.reglages) se sert de ses modules QML" >&2
        echo "et reprend la logique de ses applets. Reportez-y d'abord les changements de ${PLASMA_ATTENDU} à ${version}" >&2
        echo "(https://invent.kde.org/plasma/${rpm_plasma}), vérifiez-le en VM, puis changez PLASMA_ATTENDU" >&2
        echo "dans build_files/plasma/verifier-reglages.sh (D-052, lot 6a)." >&2
        exit 1
    fi
    echo "${rpm_plasma} ${version} : version attendue"
done

python3 -I - "${paquet}/metadata.json" << 'PYTHON'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    meta = json.load(f)
if meta["KPlugin"]["Id"] != "org.ankh.reglages":
    sys.exit(f"Paramètres rapides d'Ankh : Id « {meta['KPlugin']['Id']} » dans metadata.json")
PYTHON

# 2. qmllint : modules, types et imports. Son.qml est laissé de côté :
# plasma-pa enregistre ses types dans son code, sans fichier de description,
# et qmllint ne les voit pas ; la sonde le crée avec les vrais types.
mapfile -t fichiers < <(find "${paquet}/contents/ui" -maxdepth 1 -name '*.qml' ! -name Son.qml | sort)
if [[ ${#fichiers[@]} -eq 0 ]]; then
    echo "Paramètres rapides d'Ankh : aucun fichier QML dans ${paquet}/contents/ui" >&2
    exit 1
fi
if ! "${QT_BIN}/qmllint" -I /usr/lib64/qt6/qml --unqualified disable --missing-property disable \
    --unused-imports disable --import error --missing-type error --unresolved-type error "${fichiers[@]}"; then
    echo "Paramètres rapides d'Ankh : qmllint a trouvé un module, un type ou un import introuvable (lignes ci-dessus)" >&2
    exit 1
fi
echo "qmllint : ${#fichiers[@]} fichiers sans erreur d'import ni de type"

# 3. Sonde hors écran, dans un compte vide et sans session
travail="$(mktemp -d)"
trap 'rm -rf "${travail}"' EXIT
cp -r "${paquet}" "${travail}/paquet"
cp "${ici}/reglages-sonde.qml" "${travail}/sonde.qml"
install -d -m 0700 "${travail}/run" "${travail}/maison"
journal="${travail}/sonde.log"
if env HOME="${travail}/maison" XDG_RUNTIME_DIR="${travail}/run" XDG_CONFIG_HOME="${travail}/maison/.config" \
    XDG_CACHE_HOME="${travail}/maison/.cache" XDG_DATA_HOME="${travail}/maison/.local/share" \
    LANG=C.UTF-8 QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_FORCE_STDERR_LOGGING=1 \
    timeout 120 "${QT_BIN}/qml" "${travail}/sonde.qml" > "${journal}" 2>&1; then
    code=0
else
    code=$?
fi
cat "${journal}"
if [[ ${code} -ne 0 ]]; then
    echo "Paramètres rapides d'Ankh : la sonde a échoué (code ${code}, lignes ci-dessus)" >&2
    exit 1
fi
if grep -E 'file://[^ ]*\.qml:[0-9]+' "${journal}" > /dev/null; then
    echo "Paramètres rapides d'Ankh : avertissements QML pendant la sonde :" >&2
    grep -E 'file://[^ ]*\.qml:[0-9]+' "${journal}" >&2
    exit 1
fi
if ! grep -qE '^(qml: )?SONDE OK' "${journal}"; then
    echo "Paramètres rapides d'Ankh : la sonde n'a pas conclu (SONDE OK absent)" >&2
    exit 1
fi
echo "Paramètres rapides d'Ankh : vérifié"
