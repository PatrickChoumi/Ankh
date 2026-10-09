#!/usr/bin/bash
# D-035 : applications du quotidien présentes dès l'installation. Lancé dans
# l'image par « just test ».
set -euo pipefail

echec() {
    echo "ÉCHEC : $*" >&2
    exit 1
}

# Lanceur (.desktop) installé par les paquets d'une application
lanceur() { # $1 : motif des paquets
    local -a trouves
    mapfile -t trouves < <(rpm -qal "$1" | grep -E '^/usr/share/applications/[^/]+\.desktop$' | sort -u)
    [[ ${#trouves[@]} -eq 1 ]] || echec "paquets « $1 » : un lanceur attendu, trouvés : ${trouves[*]:-aucun}"
    basename "${trouves[0]}"
}

# Application par défaut d'un format, vue par KDE (spécification XDG)
par_defaut() { # $1 : format, $2 : lanceur attendu
    local reponse
    reponse="$(XDG_CURRENT_DESKTOP=KDE gio mime "$1")"
    [[ "${reponse}" == *": $2" ]] || echec "$1 : « ${reponse} » au lieu de $2"
}

echo "LibreOffice absent"
[[ -z "$(rpm -qa 'libreoffice*')" ]] || echec "paquets LibreOffice présents : $(rpm -qa 'libreoffice*' | tr '\n' ' ')"
for f in /usr/share/applications/*.desktop; do
    [[ "${f,,}" != *libreoffice* ]] || echec "lanceur de LibreOffice présent : ${f}"
done

echo "VLC démarre (sous un compte ordinaire : VLC refuse root)"
version="$(runuser -u nobody -- vlc --version)"
echo "${version%%$'\n'*}"
vlc="$(lanceur 'vlc*')"

echo "OnlyOffice installé dans /opt, toutes ses bibliothèques trouvées"
rpm -q onlyoffice-desktopeditors
editeurs="$(rpm -ql onlyoffice-desktopeditors | grep -m 1 '/DesktopEditors$')"
[[ "${editeurs}" == /opt/* ]] || echec "OnlyOffice hors de /opt : ${editeurs}"
# OnlyOffice apporte une partie de ses bibliothèques, dans son propre dossier :
# seules celles du système doivent manquer à l'appel pour échouer.
mapfile -t dossiers < <(find "$(dirname "${editeurs}")" -name '*.so*' -printf '%h\n' | sort -u)
LD_LIBRARY_PATH="$(
    IFS=:
    echo "${dossiers[*]}"
)" ldd "${editeurs}" > /tmp/ldd.txt
if grep 'not found' /tmp/ldd.txt; then
    echec "bibliothèques introuvables pour ${editeurs}"
fi
onlyoffice="$(lanceur onlyoffice-desktopeditors)"

echo "Applications par défaut : ${vlc} et ${onlyoffice}"
for t in video/mp4 video/x-matroska audio/mpeg audio/flac; do
    par_defaut "${t}" "${vlc}"
done
for t in application/vnd.openxmlformats-officedocument.wordprocessingml.document \
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet \
    application/vnd.openxmlformats-officedocument.presentationml.presentation \
    application/vnd.oasis.opendocument.text; do
    par_defaut "${t}" "${onlyoffice}"
done
# Le PDF et le texte brut ne sont pas confiés à OnlyOffice.
if grep -E "^(application/pdf|text/plain)=" /etc/xdg/mimeapps.list; then
    echec "PDF ou texte brut réglés dans /etc/xdg/mimeapps.list"
fi
par_defaut text/html google-chrome.desktop

echo "Applications web Claude et GitHub, installées par Chrome (D-024)"
python3 - /etc/opt/chrome/policies/managed/ankh-applications.json << 'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    applications = json.load(f)["WebAppInstallForceList"]
noms = {a["custom_name"]: a["url"] for a in applications}
attendu = {"Claude": "https://claude.ai/", "GitHub": "https://github.com/"}
if noms != attendu:
    sys.exit(f"ÉCHEC : applications web {noms} au lieu de {attendu}")
PY

echo "Applications du quotidien présentes."
