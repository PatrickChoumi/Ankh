#!/usr/bin/bash
# D-052, lot 5 : vérifications du Démarrer d'Ankh (org.ankh.demarrer) à la
# construction, dans l'étape « outils » du Containerfile, qui part de la même
# image de base que l'image d'Ankh, donc du même Plasma. Le Démarrer est un
# paquet QML dérivé de Kickoff (plasma-desktop 6.7.5) ; il se sert du module
# privé org.kde.plasma.private.kicker (plasma-workspace 6.7.5), sans promesse
# de stabilité, et une erreur QML ne fait pas tomber Plasma : le menu
# s'afficherait à moitié sans que rien n'échoue. La construction échoue donc :
# 1. si Plasma n'est plus en version 6.7.5 : les changements de Kickoff et de
#    Kicker sont à reporter d'abord (règle de D-052) ;
# 2. si qmllint trouve un module, un type ou un import introuvable ;
# 3. si la sonde (demarrer-sonde.qml), qui crée hors écran les modèles du
#    menu et le volet entier, échoue ou écrit un avertissement QML.
# Méthode et essais : recherche du lot 5 (2026-10-22), § 4.
#
# Usage : verifier-demarrer.sh [dossier du paquet org.ankh.demarrer]
set -euo pipefail

ici="$(dirname "$(readlink -f "$0")")"
paquet="$(readlink -f "${1:-${ici}/../files/usr/share/plasma/plasmoids/org.ankh.demarrer}")"
readonly PLASMA_ATTENDU=6.7.5
readonly QT_BIN=/usr/lib64/qt6/bin

echo "Démarrer d'Ankh : paquet ${paquet}"

# 1. Version de Plasma : celle dont le Démarrer est dérivé
for rpm_plasma in plasma-workspace plasma-desktop; do
    version="$(rpm -q --qf '%{VERSION}' "${rpm_plasma}")"
    if [[ "${version}" != "${PLASMA_ATTENDU}" ]]; then
        echo "Démarrer d'Ankh : ${rpm_plasma} est en version ${version}, et non ${PLASMA_ATTENDU}." >&2
        echo "Le Démarrer (build_files/files/usr/share/plasma/plasmoids/org.ankh.demarrer) est dérivé de Kickoff ${PLASMA_ATTENDU}" >&2
        echo "et se sert du module privé de Kicker. Reportez-y d'abord les changements de ${PLASMA_ATTENDU} à ${version} :" >&2
        echo "applets/kickoff de plasma-desktop et applets/kicker de plasma-workspace (https://invent.kde.org/plasma)," >&2
        echo "vérifiez-le en VM, puis changez PLASMA_ATTENDU dans build_files/plasma/verifier-demarrer.sh (D-052, lot 5)." >&2
        exit 1
    fi
    echo "${rpm_plasma} ${version} : version attendue"
done

# Le paquet : ses métadonnées (le menu doit être celui que la touche Méta et
# activateLauncherMenu ouvrent) et ses singletons
python3 -I - "${paquet}/metadata.json" << 'PYTHON'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    meta = json.load(f)
if meta["KPlugin"]["Id"] != "org.ankh.demarrer":
    sys.exit(f"Démarrer d'Ankh : Id « {meta['KPlugin']['Id']} » dans metadata.json")
if "org.kde.plasma.launchermenu" not in meta.get("X-Plasma-Provides", []):
    sys.exit("Démarrer d'Ankh : X-Plasma-Provides sans org.kde.plasma.launchermenu dans metadata.json")
PYTHON
for singleton in Mesures ActionMenu; do
    if ! grep -qx "singleton ${singleton} ${singleton}.qml" "${paquet}/contents/ui/qmldir"; then
        echo "Démarrer d'Ankh : le singleton ${singleton} n'est pas déclaré dans contents/ui/qmldir" >&2
        exit 1
    fi
done

# 2. qmllint : modules, types et imports. Les autres catégories sont
# éteintes : le typage dynamique de Kickoff y donne des faux positifs.
mapfile -t fichiers < <(find "${paquet}/contents/ui" -maxdepth 1 -name '*.qml' | sort)
if [[ ${#fichiers[@]} -eq 0 ]]; then
    echo "Démarrer d'Ankh : aucun fichier QML dans ${paquet}/contents/ui" >&2
    exit 1
fi
if ! "${QT_BIN}/qmllint" -I /usr/lib64/qt6/qml --unqualified disable --missing-property disable \
    --unused-imports disable --import error --missing-type error --unresolved-type error "${fichiers[@]}"; then
    echo "Démarrer d'Ankh : qmllint a trouvé un module, un type ou un import introuvable (lignes ci-dessus)" >&2
    exit 1
fi
echo "qmllint : ${#fichiers[@]} fichiers sans erreur d'import ni de type"

# 3. Sonde hors écran, dans un compte vide et sans session : le paquet est
# copié à côté d'elle. Sans QT_FORCE_STDERR_LOGGING, Qt de Fedora envoie ses
# messages au journal et rien n'apparaît ici. Application à widgets : les
# menus de Plasma (PlasmaExtras.Menu) sont des QMenu.
travail="$(mktemp -d)"
trap 'rm -rf "${travail}"' EXIT
cp -r "${paquet}" "${travail}/paquet"
cp "${ici}/demarrer-sonde.qml" "${travail}/sonde.qml"
install -d -m 0700 "${travail}/run" "${travail}/maison"
journal="${travail}/sonde.log"
if env HOME="${travail}/maison" XDG_RUNTIME_DIR="${travail}/run" XDG_CONFIG_HOME="${travail}/maison/.config" \
    XDG_CACHE_HOME="${travail}/maison/.cache" XDG_DATA_HOME="${travail}/maison/.local/share" \
    LANG=C.UTF-8 QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_FORCE_STDERR_LOGGING=1 \
    timeout 120 "${QT_BIN}/qml" --apptype widget "${travail}/sonde.qml" > "${journal}" 2>&1; then
    code=0
else
    code=$?
fi
cat "${journal}"
if [[ ${code} -ne 0 ]]; then
    echo "Démarrer d'Ankh : la sonde a échoué (code ${code}, lignes ci-dessus)" >&2
    exit 1
fi
# Tout avertissement d'un fichier QML (« file://….qml:L: » ou « :L:C: ») :
# valeur d'énumération disparue, propriété introuvable à l'exécution…
if grep -E 'file://[^ ]*\.qml:[0-9]+' "${journal}" > /dev/null; then
    echo "Démarrer d'Ankh : avertissements QML pendant la sonde :" >&2
    grep -E 'file://[^ ]*\.qml:[0-9]+' "${journal}" >&2
    exit 1
fi
# console.warn préfixe ses messages de « qml: » dans l'outil qml
if ! grep -qE '^(qml: )?SONDE OK' "${journal}"; then
    echo "Démarrer d'Ankh : la sonde n'a pas conclu (SONDE OK absent)" >&2
    exit 1
fi
echo "Démarrer d'Ankh : vérifié"
