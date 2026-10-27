#!/usr/bin/bash
# D-052, lot 8b : Dolphin disposé comme l'Explorateur de Windows 11 (mon
# choix du 2026-10-24). Écrit le fichier des barres de Dolphin pour l'image,
# /usr/share/kxmlgui5/dolphin/dolphinui.rc, à partir du Dolphin de cette image
# de base :
# 1. Dolphin est lancé hors écran, dans un compte vide et une session D-Bus à
#    lui, avec barres-ankh.rc (version 1) comme fichier du compte : KXMLGUI le
#    fusionne dans le fichier de Dolphin, compilé dans le programme (version
#    plus grande), et écrit le résultat dans le compte. Les menus restent ceux
#    de ce Dolphin, quelle que soit sa version ;
# 2. preparer-dolphinui.py vérifie la fusion et remet les barres dans l'ordre ;
# 3. Dolphin est relancé avec ce fichier dans un dossier de données du système
#    (XDG_DATA_DIRS), à la même version que le sien : KXMLGUI prend le premier
#    trouvé, celui d'Ankh, sans rien écrire dans le compte. Les actions des
#    barres doivent y être branchées (org.kde.KMainWindow.actions) et les
#    boutons témoins porter le texte d'Ankh (iconText, lu par D-Bus).
# Un fichier du compte, écrit par « Configurer les barres d'outils », passe
# avant celui d'Ankh, comme dans KDE.
#
# Usage : generer-dolphinui.sh <dossier de sortie>
#         (dolphinui.rc et version, la version du paquet dolphin)
set -euo pipefail

ici="$(dirname "$(readlink -f "$0")")"

# Dans la session D-Bus de Dolphin : le lance, attend qu'il réponde, lit ses
# actions branchées et le texte des boutons témoins, puis l'arrête.
if [[ "${1:-}" == "--dans-la-session" ]]; then
    resultats=$2
    shift 2
    bus=(busctl --address="${DBUS_SESSION_BUS_ADDRESS}" --json=short)
    dolphin "${HOME}" > "${resultats}/dolphin.log" 2>&1 &
    pid=$!
    nom="org.kde.dolphin-${pid}"
    for _ in $(seq 1 60); do
        if "${bus[@]}" call "${nom}" /dolphin/Dolphin_1 org.kde.KMainWindow actions > "${resultats}/actions" 2> /dev/null; then
            break
        fi
        if ! kill -0 "${pid}" 2> /dev/null; then
            cat "${resultats}/dolphin.log" >&2
            echo "Barres de Dolphin : Dolphin s'est arrêté seul (journal ci-dessus)" >&2
            exit 1
        fi
        sleep 0.5
    done
    if [[ ! -s "${resultats}/actions" ]]; then
        cat "${resultats}/dolphin.log" >&2
        echo "Barres de Dolphin : Dolphin ne répond pas sur D-Bus après 30 s" >&2
        exit 1
    fi
    for action in "$@"; do
        printf '%s %s\n' "${action}" \
            "$("${bus[@]}" get-property "${nom}" "/dolphin/Dolphin_1/actions/${action}" org.qtproject.Qt.QAction iconText)" \
            >> "${resultats}/textes"
    done
    kill "${pid}"
    # Arrêté par kill : code 143 (SIGTERM). Tout autre code : il a planté.
    if wait "${pid}"; then
        code=0
    else
        code=$?
    fi
    if [[ ${code} -ne 143 ]]; then
        cat "${resultats}/dolphin.log" >&2
        echo "Barres de Dolphin : Dolphin s'est arrêté avec le code ${code}" >&2
        exit 1
    fi
    exit 0
fi

sortie=$1
travail="$(mktemp -d)"
trap 'rm -rf "${travail}"' EXIT
readonly LOCAL=.local/share/kxmlgui5/dolphin/dolphinui.rc

# Lance Dolphin dans un compte vide : $1 dossier du lancement, $2 dossiers de
# données ajoutés devant ceux du système (ou vide), puis les boutons témoins
lancer() {
    local dossier=$1 donnees=$2
    shift 2
    install -d -m 0700 "${dossier}/run"
    mkdir -p "${dossier}/maison/.config"
    env -i PATH=/usr/bin:/usr/sbin HOME="${dossier}/maison" XDG_RUNTIME_DIR="${dossier}/run" \
        XDG_DATA_DIRS="${donnees:+${donnees}:}/usr/local/share:/usr/share" LANG=C.UTF-8 \
        QT_QPA_PLATFORM=offscreen QT_FORCE_STDERR_LOGGING=1 \
        dbus-run-session -- "${ici}/generer-dolphinui.sh" --dans-la-session "${dossier}" "$@"
}

# 1. La fusion
mkdir -p "${travail}/fusion/maison/$(dirname "${LOCAL}")"
install -m 0644 "${ici}/barres-ankh.rc" "${travail}/fusion/maison/${LOCAL}"
lancer "${travail}/fusion" ""

# 2. Vérifiée, les barres remises dans l'ordre
mkdir -p "${travail}/donnees/kxmlgui5/dolphin"
python3 "${ici}/preparer-dolphinui.py" preparer "${ici}/barres-ankh.rc" \
    "${travail}/fusion/maison/${LOCAL}" "${travail}/donnees/kxmlgui5/dolphin/dolphinui.rc"

# 3. Lu par Dolphin depuis les données du système, sans rien écrire dans le
# compte (au premier lancement, Dolphin écrit le sien s'il doit y ajouter son
# menu : addHamburgerMenuToToolbar)
lancer "${travail}/verification" "${travail}/donnees" sort view_settings
if [[ -e "${travail}/verification/maison/${LOCAL}" ]]; then
    echo "Barres de Dolphin : Dolphin a écrit un fichier de barres dans le compte" >&2
    exit 1
fi
python3 "${ici}/preparer-dolphinui.py" verifier "${ici}/barres-ankh.rc" \
    "${travail}/verification/actions" "${travail}/verification/textes"

install -d -m 0755 "${sortie}"
install -m 0644 "${travail}/donnees/kxmlgui5/dolphin/dolphinui.rc" "${sortie}/dolphinui.rc"
rpm -q --qf '%{VERSION}-%{RELEASE}\n' dolphin > "${sortie}/version"
echo "Barres de Dolphin : écrites pour Dolphin $(cat "${sortie}/version")"
