#!/usr/bin/bash
# D-052, lot 7a : vérifications d'Alt+Tab d'Ankh (paquet KWin/WindowSwitcher
# org.ankh.alttab) à la construction, dans l'étape « outils » du
# Containerfile, sur le KWin et le Plasma de la même image de base. Une
# erreur QML dans le sélecteur ne fait pas tomber KWin : Alt+Tab n'afficherait
# rien, ou la grille de KDE, sans que rien n'échoue. La construction échoue
# donc :
# 1. si KWin n'est plus en version 6.7.5 : ses changements du sélecteur de
#    fenêtres (src/tabbox) sont à reporter d'abord (règle de D-052) ;
# 2. si metadata.json ne décrit plus un sélecteur de fenêtres d'Id
#    org.ankh.alttab ;
# 3. si qmllint trouve un module, un type ou un import introuvable dans le
#    sélecteur (Selecteur.qml) ou le module commun d'Ankh. main.qml importe
#    org.kde.kwin, qui n'existe que dans KWin : qmllint n'y vérifie que la
#    syntaxe ;
# 4. si la sonde (alttab-sonde.qml), qui crée le sélecteur hors écran avec
#    de fausses fenêtres, échoue ou écrit un avertissement QML.
#
# Usage : verifier-alttab.sh [dossier du paquet org.ankh.alttab]
set -euo pipefail

ici="$(dirname "$(readlink -f "$0")")"
paquet="$(readlink -f "${1:-${ici}/../files/usr/share/kwin-wayland/tabbox/org.ankh.alttab}")"
modules="$(readlink -f "${ici}/../files/usr/lib64/qt6/qml")"
readonly KWIN_ATTENDU=6.7.5
readonly QT_BIN=/usr/lib64/qt6/bin

echo "Alt+Tab d'Ankh : paquet ${paquet}"

# 1. Version de KWin
version="$(rpm -q --qf '%{VERSION}' kwin)"
if [[ "${version}" != "${KWIN_ATTENDU}" ]]; then
    echo "Alt+Tab d'Ankh : KWin est en version ${version}, et non ${KWIN_ATTENDU}." >&2
    echo "Le paquet build_files/files/usr/share/kwin-wayland/tabbox/org.ankh.alttab suit le sélecteur de fenêtres" >&2
    echo "de KWin (src/tabbox). Reportez-y d'abord les changements de ${KWIN_ATTENDU} à ${version}" >&2
    echo "(https://invent.kde.org/plasma/kwin), vérifiez-le en VM, puis changez KWIN_ATTENDU" >&2
    echo "dans build_files/plasma/verifier-alttab.sh (D-052, lot 7a)." >&2
    exit 1
fi
echo "kwin ${version} : version attendue"

# 2. metadata.json
python3 -I - "${paquet}/metadata.json" << 'PYTHON'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    meta = json.load(f)
if meta.get("KPackageStructure") != "KWin/WindowSwitcher" or meta["KPlugin"]["Id"] != "org.ankh.alttab":
    sys.exit(f"Alt+Tab d'Ankh : metadata.json décrit « {meta.get('KPackageStructure')} », Id « {meta['KPlugin']['Id']} »")
PYTHON

# 3. qmllint
mapfile -t fichiers < <(find "${paquet}/contents/ui" "${modules}/org/ankh/commun" -maxdepth 1 -name '*.qml' ! -name main.qml | sort)
if ! "${QT_BIN}/qmllint" -I "${modules}" -I /usr/lib64/qt6/qml --unqualified disable --missing-property disable \
    --unused-imports disable --import error --missing-type error --unresolved-type error "${fichiers[@]}"; then
    echo "Alt+Tab d'Ankh : qmllint a trouvé un module, un type ou un import introuvable (lignes ci-dessus)" >&2
    exit 1
fi
if ! "${QT_BIN}/qmllint" -I "${modules}" -I /usr/lib64/qt6/qml --import disable --missing-type disable \
    --unresolved-type disable --unqualified disable --missing-property disable --unused-imports disable \
    "${paquet}/contents/ui/main.qml"; then
    echo "Alt+Tab d'Ankh : main.qml ne se lit pas (lignes ci-dessus)" >&2
    exit 1
fi
echo "qmllint : $(( ${#fichiers[@]} + 1 )) fichiers sans erreur"

# 4. Sonde hors écran, dans un compte vide et sans session
travail="$(mktemp -d)"
trap 'rm -rf "${travail}"' EXIT
cp -r "${paquet}" "${travail}/paquet"
cp "${ici}/alttab-sonde.qml" "${travail}/sonde.qml"
install -d -m 0700 "${travail}/run" "${travail}/maison"
journal="${travail}/sonde.log"
if env HOME="${travail}/maison" XDG_RUNTIME_DIR="${travail}/run" XDG_CONFIG_HOME="${travail}/maison/.config" \
    XDG_CACHE_HOME="${travail}/maison/.cache" XDG_DATA_HOME="${travail}/maison/.local/share" \
    LANG=C.UTF-8 QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_FORCE_STDERR_LOGGING=1 \
    QML_IMPORT_PATH="${modules}" timeout 120 "${QT_BIN}/qml" "${travail}/sonde.qml" > "${journal}" 2>&1; then
    code=0
else
    code=$?
fi
cat "${journal}"
if [[ ${code} -ne 0 ]]; then
    echo "Alt+Tab d'Ankh : la sonde a échoué (code ${code}, lignes ci-dessus)" >&2
    exit 1
fi
if grep -E 'file://[^ ]*\.qml:[0-9]+' "${journal}" > /dev/null; then
    echo "Alt+Tab d'Ankh : avertissements QML pendant la sonde :" >&2
    grep -E 'file://[^ ]*\.qml:[0-9]+' "${journal}" >&2
    exit 1
fi
if ! grep -qE '^(qml: )?SONDE OK' "${journal}"; then
    echo "Alt+Tab d'Ankh : la sonde n'a pas conclu (SONDE OK absent)" >&2
    exit 1
fi
echo "Alt+Tab d'Ankh : vérifié"
