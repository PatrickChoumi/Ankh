#!/usr/bin/bash
# D-034 : plus rien de Fedora à l'écran. Lancé dans l'image par « just test ».
# Chaque élément visible au nom de Fedora est affiché avec le paquet qui le
# fournit ; le test échoue s'il en reste un. Sous le capot (paquets, noyau,
# ID=fedora), Fedora reste, et ce test ne le regarde pas.
set -euo pipefail

trouves=0

signaler() { # $1 : ce qui est visible, $2 : fichier
    local paquet="aucun paquet"
    if rpm -qf "$2" > /dev/null 2>&1; then
        paquet="paquet $(rpm -qf --qf '%{NAME} ' "$2")"
    fi
    echo "FEDORA VISIBLE : $1 : $2 (${paquet})" >&2
    trouves=$((trouves + 1))
}

# Paquets dont tout le contenu est de l'habillage Fedora
for p in fedora-logos plasma-welcome-fedora; do
    if rpm -q "${p}" > /dev/null; then
        echo "FEDORA VISIBLE : paquet ${p} installé" >&2
        trouves=$((trouves + 1))
    fi
done

# Nom du système
# shellcheck source=/dev/null
. /etc/os-release
if [[ "${NAME,,}" == *fedora* || "${PRETTY_NAME,,}" == *fedora* ]]; then
    signaler "nom du système" /etc/os-release
fi

# Entrées du menu des applications (nom, description, info-bulle)
for f in /usr/share/applications/*.desktop; do
    if grep -qiE '^(NoDisplay|Hidden)=true' "${f}"; then
        continue
    fi
    if grep -qiE '^(Name|GenericName|Comment)(\[[^]]*\])?=.*fedora' "${f}"; then
        signaler "entrée du menu" "${f}"
    fi
done

# Thèmes globaux, thèmes Plasma et fonds d'écran : nom affiché
for f in /usr/share/plasma/look-and-feel/*/metadata.json /usr/share/plasma/desktoptheme/*/metadata.json \
    /usr/share/wallpapers/*/metadata.json /usr/share/wallpapers/*/metadata.desktop; do
    if [[ ! -e "${f}" ]]; then
        continue
    fi
    # Toute mention de Fedora, sauf l'identifiant du paquet, qui ne se voit pas
    if grep -viE '"Id" *:|^X-KDE-PluginInfo-Name=' "${f}" | grep -qi fedora; then
        signaler "thème ou fond d'écran" "${f}"
    fi
done

# Aperçus des thèmes globaux venus de Fedora : ceux d'Ankh
for d in /usr/share/plasma/look-and-feel/org.fedoraproject.*/; do
    for apercu in preview.png fullscreenpreview.jpg lockscreen.png; do
        if [[ -e "${d}contents/previews/${apercu}" ]] && ! cmp -s "/usr/share/ankh/apercus/${apercu}" "${d}contents/previews/${apercu}"; then
            signaler "aperçu de thème global" "${d}contents/previews/${apercu}"
        fi
    done
done

# Fonds d'écran de Fedora, nommés par version (F44…) ou « Fedora »
for d in /usr/share/wallpapers/*/; do
    nom="$(basename "${d}")"
    if [[ "${nom,,}" == fedora* || "${nom}" =~ ^F[0-9]+ ]]; then
        signaler "fond d'écran" "${d}"
    fi
done

# Schémas de couleurs
for f in /usr/share/color-schemes/*.colors; do
    if [[ -e "${f}" ]] && grep -qiE '^Name(\[[^]]*\])?=.*fedora' "${f}"; then
        signaler "schéma de couleurs" "${f}"
    fi
done

# Dépôt Flatpak de Fedora, visible dans Discover : aucun fichier de dépôt, et
# le service qui l'ajoute au premier démarrage est masqué
for f in /etc/flatpak/remotes.d/fedora.flatpakrepo /usr/share/flatpak/remotes.d/fedora.flatpakrepo; do
    if [[ -e "${f}" ]]; then
        signaler "dépôt Flatpak de Fedora" "${f}"
    fi
done
service=flatpak-add-fedora-repos.service
if [[ -e "/usr/lib/systemd/system/${service}" && "$(readlink "/etc/systemd/system/${service}")" != /dev/null ]]; then
    signaler "service qui ajoute le dépôt Flatpak de Fedora" "/usr/lib/systemd/system/${service}"
fi

# Écran de démarrage : le filigrane d'Ankh, dans le thème et dans l'initramfs
theme="$(plymouth-set-default-theme)"
images="$(realpath -m "$(sed -n 's/^ImageDir=//p' "/usr/share/plymouth/themes/${theme}/${theme}.plymouth")")"
echo "Thème Plymouth : ${theme} (${images})"
reference=/usr/share/ankh/plymouth/watermark.png
if ! cmp -s "${reference}" "${images}/watermark.png"; then
    signaler "logo de l'écran de démarrage" "${images}/watermark.png"
fi
kver="$(basename /usr/lib/modules/*)"
initramfs="/usr/lib/modules/${kver}/initramfs.img"
if ! lsinitrd -f "${images#/}/watermark.png" "${initramfs}" | cmp -s "${reference}" -; then
    signaler "logo de l'écran de démarrage dans l'initramfs" "${initramfs}"
fi

if ((trouves > 0)); then
    # Inventaire pour savoir quoi traiter : contenu des paquets d'habillage de
    # Fedora encore présents, et réglages qui font référence à leurs fichiers.
    for p in plasma-lookandfeel-fedora f44-backgrounds-kde; do
        if rpm -q "${p}" > /dev/null; then
            echo "--- Contenu de ${p} :" >&2
            rpm -ql "${p}" | sed '/\/contents\/images/d' >&2
        fi
    done
    dossiers=()
    for d in /etc /usr/share/plasma /usr/share/kde-settings /usr/lib/plasmalogin /usr/share/plasmalogin; do
        if [[ -d "${d}" ]]; then
            dossiers+=("${d}")
        fi
    done
    echo "--- Réglages qui citent un fond ou un thème de Fedora :" >&2
    if ! grep -rIns --exclude=metadata.json -e 'wallpapers/Fedora' -e 'wallpapers/F44' -e 'wallpapers/Default' \
        -e 'org.fedoraproject' -e 'LookAndFeelPackage' -e 'backgrounds/' "${dossiers[@]}" >&2; then
        echo "(aucun)" >&2
    fi
    echo "--- Fonds d'écran présents :" >&2
    ls -la /usr/share/wallpapers >&2
    echo "ÉCHEC : ${trouves} élément(s) au nom de Fedora visibles" >&2
    exit 1
fi
echo "Rien de Fedora à l'écran."
