#!/usr/bin/bash
# D-035, D-053 : applications du quotidien présentes dès l'installation.
# Lancé dans l'image par « just test ».
set -euo pipefail

echec() {
    echo "ÉCHEC : $*" >&2
    exit 1
}

# Lanceur principal d'une application : il porte son nom et appartient à
# l'un de ses paquets
lanceur() { # $1 : nom de l'application et de son paquet principal
    local fichier="/usr/share/applications/$1.desktop"
    [[ "$(rpm -qf --qf '%{NAME}' "${fichier}")" == "$1"* ]] || echec "lanceur ${fichier} absent, ou étranger aux paquets « $1 »"
    basename "${fichier}"
}

# Application par défaut d'un format, vue par KDE (spécification XDG)
par_defaut() { # $1 : format, $2 : lanceur attendu
    local reponse
    reponse="$(XDG_CURRENT_DESKTOP=KDE gio mime "$1")"
    # Première ligne : « Default application for “…”: lanceur.desktop »
    reponse="${reponse%%$'\n'*}"
    [[ "${reponse}" == "Default application for "*": $2" ]] || echec "$1 : « ${reponse} » au lieu de $2"
}

echo "LibreOffice absent"
[[ -z "$(rpm -qa 'libreoffice*')" ]] || echec "paquets LibreOffice présents : $(rpm -qa 'libreoffice*' | tr '\n' ' ')"
for f in /usr/share/applications/*.desktop; do
    [[ "${f,,}" != *libreoffice* ]] || echec "lanceur de LibreOffice présent : ${f}"
done

echo "VLC démarre (sous un compte ordinaire : VLC refuse root)"
version="$(runuser -u nobody -- vlc --version)"
echo "${version%%$'\n'*}"
vlc="$(lanceur vlc)"

# D-053 : la bureautique vient de la suite Craft (tests/craft.sh), préparée
# au premier clic : ses entrées du menu sont dans l'image dès l'installation.
echo "Applications par défaut : ${vlc}, WordCraft, GridCraft et DeckCraft"
for t in video/mp4 video/x-matroska audio/mpeg audio/flac; do
    par_defaut "${t}" "${vlc}"
done
for t in application/vnd.openxmlformats-officedocument.wordprocessingml.document \
    application/msword application/vnd.oasis.opendocument.text application/rtf; do
    par_defaut "${t}" ai.storyteller.wordcraft.desktop
done
for t in application/vnd.openxmlformats-officedocument.spreadsheetml.sheet \
    application/vnd.oasis.opendocument.spreadsheet text/csv; do
    par_defaut "${t}" ai.storyteller.gridcraft.desktop
done
par_defaut application/vnd.openxmlformats-officedocument.presentationml.presentation ai.storyteller.deckcraft.desktop
# Les autres formats que la suite déclare (PDF, images, texte brut) ne lui
# sont pas confiés quand une application de l'image les ouvre déjà : Chrome,
# au moins, ouvre le PDF et les images.
for t in application/pdf image/png image/jpeg text/plain; do
    reponse="$(XDG_CURRENT_DESKTOP=KDE gio mime "${t}")"
    reponse="${reponse%%$'\n'*}"
    echo "${t} : ${reponse}"
    if grep -q "^${t}=" /etc/xdg/mimeapps.list; then
        [[ "${reponse}" != *ai.storyteller.* ]] || echec "${t} est confié à la suite Craft alors qu'une application de l'image l'ouvre"
    elif [[ "${t}" != text/plain ]]; then
        echec "${t} n'a pas d'application par défaut dans /etc/xdg/mimeapps.list"
    fi
done
par_defaut text/html google-chrome.desktop

echo "Aucune application web imposée par Chrome (D-047)"
if grep -rls WebAppInstallForceList /etc/opt/chrome /etc/opt/google; then
    echec "une politique de Chrome installe encore des applications web"
fi

echo "Applications du quotidien présentes."
