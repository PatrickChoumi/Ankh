#!/usr/bin/bash
# Personnalisations d'Ankh appliquées pendant la construction de l'image.
# Chaque ajout cite la décision qui le justifie (DECISIONS.md) et a son test
# dans « just test ».
set -euo pipefail

# D-010 : pas de redémarrage automatique. Ce timer peut télécharger, appliquer
# une mise à jour puis redémarrer la machine ; la documentation Fedora bootc
# recommande de le masquer pendant la construction de l'image pour l'éviter.
# https://docs.fedoraproject.org/en-US/bootc/auto-updates/
systemctl mask bootc-fetch-apply-updates.timer

# D-028 : les mises à jour du système s'affichent dans Discover. kinoite-main
# retire ce module ; KDE a corrigé depuis le problème qui avait motivé ce
# retrait (https://github.com/ublue-os/main/pull/282). Le module ne redémarre
# jamais seul : il signale qu'un redémarrage est nécessaire (D-010).
dnf5 -y install plasma-discover-rpm-ostree

# D-023 : Chrome, navigateur par défaut, depuis le dépôt officiel de Google.
# /opt devient un vrai dossier de l'image au lieu d'un lien vers /var/opt :
# Chrome s'installe dans /opt et doit suivre les mises à jour de l'image.
# Méthode du modèle Universal Blue (« rm /opt && mkdir /opt », qui cite
# Chrome en exemple : https://github.com/ublue-os/image-template).
rm /opt
mkdir /opt

# Clé de signature de Google, refusée si son empreinte n'est pas celle publiée
# dans les sources de Chromium (chrome/installer/linux/common/key.include).
google_fpr=EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796
google_key=/etc/pki/rpm-gpg/google-linux-signing-key.pub
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub -o "${google_key}"
# Dossier temporaire pour gpg : /root pointe vers /var/roothome, qui n'existe
# pas pendant la construction (« can't create directory '/root/.gnupg' »).
gnupg_home=$(mktemp -d)
fpr=$(gpg --homedir "${gnupg_home}" --show-keys --with-colons "${google_key}" | awk -F: '/^fpr:/ {print $10; exit}')
rm -rf "${gnupg_home}"
if [[ "${fpr}" != "${google_fpr}" ]]; then
    echo "Clé de Google inattendue : ${fpr} (attendu ${google_fpr})" >&2
    exit 1
fi
rpm --import "${google_key}"
cat > /etc/yum.repos.d/google-chrome.repo << REPO
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=file://${google_key}
REPO
dnf5 -y install google-chrome-stable

# D-023 : Firefox est retiré (un seul navigateur, une seule porte à protéger).
dnf5 -y remove firefox

# D-023 : Chrome par défaut pour les pages web, dans KDE comme pour les autres
# bureaux (spécification XDG des applications par défaut). Les fichiers sont
# créés seulement s'ils n'existent pas : on n'écrase jamais un réglage de la
# base sans le voir.
for f in /etc/xdg/mimeapps.list /etc/xdg/kdeglobals; do
    if [[ -e "${f}" ]]; then
        echo "${f} existe déjà dans la base : réglage à fusionner à la main" >&2
        exit 1
    fi
done
cat > /etc/xdg/mimeapps.list << 'MIME'
[Default Applications]
text/html=google-chrome.desktop
application/xhtml+xml=google-chrome.desktop
x-scheme-handler/http=google-chrome.desktop
x-scheme-handler/https=google-chrome.desktop
MIME
cat > /etc/xdg/kdeglobals << 'KDE'
[General]
BrowserApplication=google-chrome.desktop
KDE

# D-035 : les applications du quotidien sont dans l'image dès l'installation,
# comme Chrome (modifie D-011 et D-024) : VLC. Il se met à jour avec l'image,
# chaque semaine (D-023, D-031). La bureautique vient de la suite Craft
# (D-053, plus bas), qui remplace OnlyOffice.
#
# LibreOffice est retiré : une seule suite bureautique. Tous ses paquets,
# s'il y en a dans la base. La liste de ce qui part est affichée.
mapfile -t libreoffice < <(rpm -qa --qf '%{NAME}\n' 'libreoffice*' | sort -u)
if [[ ${#libreoffice[@]} -gt 0 ]]; then
    avant="$(rpm -qa --qf '%{NAME}\n' | sort -u)"
    dnf5 -y remove "${libreoffice[@]}"
    echo "Retirés avec LibreOffice : $(comm -23 <(echo "${avant}") <(rpm -qa --qf '%{NAME}\n' | sort -u) | tr '\n' ' ')"
else
    echo "LibreOffice absent de la base : rien à retirer"
fi

# VLC, depuis les dépôts de la base : celui de Fedora, ou celui de negativo17
# (codecs complets), que kinoite-main active en priorité
# (build_files/install.sh de https://github.com/ublue-os/main).
dnf5 -y install vlc
rpm -q --qf 'VLC installé : %{NAME} %{VERSION}-%{RELEASE} (%{VENDOR})\n' vlc

# D-053 : la suite Craft d'ArtCraft (https://github.com/storytold), à la place
# d'OnlyOffice : WordCraft, GridCraft et DeckCraft dans Simple (entrées du menu
# dans /usr/share/applications), les sept autres avec l'option Création
# (/usr/share/ankh/options/creation/applications). Elles ne sont pas sur
# Flathub : chaque version publie, dans ses « Releases » GitHub, un Flatpak en
# un seul fichier (<nom>-<version>-linux-x86_64.flatpak) et les empreintes
# SHA256 de ses fichiers (SHA256SUMS.txt). La dernière version de chacune, et
# l'empreinte de son Flatpak, sont figées ici dans l'image
# (/usr/share/ankh/craft/versions) : /usr/libexec/ankh-craft le télécharge au
# premier clic, et refuse un fichier d'une autre empreinte. La construction
# échoue s'il manque le Flatpak x86_64 ou son empreinte.
# Les entrées, les icônes, le lanceur, son service et sa règle polkit sont
# dans build_files/files (copiés plus bas).
# Ce changement touche à polkit (/usr/share/polkit-1/rules.d/50-ankh-craft.rules) :
# à relire.
craft_entrees=(/ctx/files/usr/share/applications/ai.storyteller.*.desktop
    /ctx/files/usr/share/ankh/options/creation/applications/ai.storyteller.*.desktop)
craft_versions=/usr/share/ankh/craft/versions
install -d -m 0755 "$(dirname "${craft_versions}")"
{
    echo "# Suite Craft (D-053) : version et empreinte SHA256 du Flatpak x86_64 de"
    echo "# chaque application, figées à la construction de l'image ($(date -u +%Y-%m-%d))."
    echo "# option nom version empreinte adresse"
    for entree in "${craft_entrees[@]}"; do
        nom="$(basename "${entree}" .desktop)"
        nom="${nom#ai.storyteller.}"
        case "${entree}" in
            /ctx/files/usr/share/applications/*) option=simple ;;
            *) option=creation ;;
        esac
        sommes="$(curl -fsSL --retry 3 "https://github.com/storytold/${nom}/releases/latest/download/SHA256SUMS.txt")"
        # awk plutôt que grep : aucune ligne n'est un résultat, pas une erreur
        lignes="$(awk -v nom="${nom}" '$1 ~ /^[0-9a-f]+$/ && length($1) == 64 && NF == 2 &&
            $2 ~ ("^" nom "-[0-9]+[.][0-9]+[.][0-9]+-linux-x86_64[.]flatpak$")' <<< "${sommes}")"
        if [[ -z "${lignes}" || "$(wc -l <<< "${lignes}")" -ne 1 ]]; then
            echo "${nom} : pas un seul Flatpak x86_64 dans SHA256SUMS.txt de sa dernière version :" >&2
            echo "${sommes}" >&2
            exit 1
        fi
        empreinte="${lignes%% *}"
        fichier="${lignes##* }"
        version="${fichier#"${nom}-"}"
        version="${version%-linux-x86_64.flatpak}"
        adresse="https://github.com/storytold/${nom}/releases/download/v${version}/${fichier}"
        # Le fichier existe bien à cette adresse (sans le télécharger)
        curl -fsSIL --retry 3 -o /dev/null "${adresse}"
        echo "${option} ${nom} ${version} ${empreinte} ${adresse}"
    done
} > "${craft_versions}"
chmod 0644 "${craft_versions}"
cat "${craft_versions}"
if [[ "$(grep -c '^simple ' "${craft_versions}")" -ne 3 || "$(grep -c '^creation ' "${craft_versions}")" -ne 7 ]]; then
    echo "Suite Craft : 3 applications dans Simple et 7 dans Création attendues" >&2
    exit 1
fi

# Applications par défaut (spécification XDG, comme Chrome plus haut) : VLC
# pour la vidéo et l'audio, WordCraft, GridCraft et DeckCraft pour les
# documents de bureau. Les formats sont ceux que chaque application déclare
# dans son lanceur, filtrés : WordCraft déclare aussi le texte brut et le HTML.
# Le lanceur principal de VLC porte son nom et appartient à l'un de ses
# paquets (VLC en a d'autres, pour ouvrir un DVD, un Blu-ray…).
lanceur() { # $1 : nom de l'application et de son paquet principal
    local fichier="/usr/share/applications/$1.desktop"
    if [[ "$(rpm -qf --qf '%{NAME}' "${fichier}")" != "$1"* ]]; then
        echo "Lanceur ${fichier} absent, ou étranger aux paquets « $1 ». Lanceurs de ces paquets :" \
            "$(rpm -qal "$1*" | grep '^/usr/share/applications/' | tr '\n' ' ')" >&2
        return 1
    fi
    echo "${fichier}"
}
formats() { # $1 : lanceur, $2 : formats retenus (expression régulière)
    sed -n 's/^MimeType=//p' "$1" | tr ';' '\n' | grep -E "$2" | sort -u
}
par_defaut() { # $1 : lanceur, $2 : formats retenus ; au moins un format
    local t n=0
    while IFS= read -r t; do
        echo "${t}=$(basename "$1")" >> /etc/xdg/mimeapps.list
        n=$((n + 1))
    done < <(formats "$1" "$2")
    if ((n == 0)); then
        echo "Aucun format retenu pour $1" >&2
        return 1
    fi
    echo "$(basename "$1") par défaut pour ${n} formats"
}
bureautique='^(application/(msword|rtf|vnd\.ms-(excel|powerpoint|word)|vnd\.openxmlformats-officedocument\.|vnd\.oasis\.opendocument\.(text|spreadsheet|presentation))|text/(csv|rtf)$)'
vlc_lanceur="$(lanceur vlc)"
par_defaut "${vlc_lanceur}" '^(video|audio)/'
for nom in wordcraft gridcraft deckcraft; do
    par_defaut "/ctx/files/usr/share/applications/ai.storyteller.${nom}.desktop" "${bureautique}"
done
# Les autres formats que déclare la suite Craft (texte brut, PDF, images…)
# restent aux applications de l'image qui les ouvrent déjà, pour qu'une
# application en alpha ne les prenne pas une fois installée : Flatpak place
# ses entrées du menu devant celles de /usr/share (XDG_DATA_DIRS, voir
# /usr/libexec/ankh-flatpak). Pour chaque format, la première de ces
# applications qui le déclare ; sans elle, KDE choisit.
gardiens=(org.kde.gwenview.desktop org.kde.okular.desktop org.kde.kwrite.desktop org.kde.kate.desktop
    google-chrome.desktop)
laisses=()
while IFS= read -r t; do
    if awk -F= -v t="${t}" '$1 == t { trouve = 1 } END { exit !trouve }' /etc/xdg/mimeapps.list; then
        continue
    fi
    gardien=""
    for candidat in "${gardiens[@]}"; do
        if [[ -f "/usr/share/applications/${candidat}" ]] &&
            sed -n 's/^MimeType=//p' "/usr/share/applications/${candidat}" | tr ';' '\n' | grep -qxF "${t}"; then
            gardien="${candidat}"
            break
        fi
    done
    if [[ -n "${gardien}" ]]; then
        echo "${t}=${gardien}" >> /etc/xdg/mimeapps.list
        echo "${t} : reste à ${gardien}"
    else
        laisses+=("${t}")
    fi
done < <(sed -n 's/^MimeType=//p' "${craft_entrees[@]}" | tr ';' '\n' | grep -v '^$' | sort -u)
echo "Formats de la suite Craft laissés au choix de KDE : ${laisses[*]:-aucun}"

# D-047 : Chrome n'installe plus d'applications web de lui-même (Claude et
# GitHub, D-024) : je les installe moi-même si je les veux. Aucune politique
# WebAppInstallForceList n'est fournie (vérifié par le Test 12).

# D-031 : aucune mise à jour automatique sur la machine. Je décide quand mettre
# à jour ; Discover me prévient qu'une mise à jour existe (D-028).
# kinoite-main active ces timers (ublue-os/main, build_files/post-install.sh) :
# téléchargement du système en arrière-plan, mises à jour Flatpak du système
# et de chaque utilisateur. Ils sont masqués, et la politique de rpm-ostree
# passe à « none » (man rpm-ostreed.conf : « "none" disables automatic updates »).
systemctl mask rpm-ostreed-automatic.timer flatpak-system-update.timer
systemctl --global mask flatpak-user-update.timer
sed -i 's/^AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=none/' /etc/rpm-ostreed.conf
grep -qx 'AutomaticUpdatePolicy=none' /etc/rpm-ostreed.conf

# D-004 : une mise à jour préparée doit s'appliquer au redémarrage. Quand
# /boot n'a pas de partition à lui (« bootc install to-disk » en btrfs),
# ostree y lie /sysroot/boot (boot.mount, ostree-system-generator) ; mais
# /boot paraît vide quand systemd-gpt-auto-generator passe, et celui-ci y
# ajoute un montage automatique de la partition EFI (boot.automount), qui se
# démonte après 2 minutes d'inactivité (src/gpt-auto-generator dans
# https://github.com/systemd/systemd). Vu en VM : à l'arrêt, la finalisation
# par ostree n'a plus trouvé son /boot (« Remounting /boot read-write: Invalid
# argument ») et l'ancienne version a redémarré. Ce montage automatique est
# masqué ; /boot reste celui d'ostree. Quand /boot a sa propre partition,
# systemd ne crée pas ce montage automatique : le masque est sans effet.
systemctl mask boot.automount

# D-032 : conteneur de dev. L'image Ankh apporte sa description pour distrobox
# et deux raccourcis du menu, pour le créer et le mettre à jour quand je le
# décide (D-031). Le socket Podman de l'utilisateur est activé pour que le
# conteneur de dev pilote les conteneurs du système (bases de données).
# Les fichiers appartiennent à root, quel que soit le propriétaire dans la CI.
cp -a --no-preserve=ownership /ctx/files/. /
systemctl --global enable podman.socket

# D-041, D-050 : outils du jeu dans le système, pour l'option Gaming :
# - GameMode, qui sert aussi les jeux en Flatpak par le portail GameMode
#   (data/org.freedesktop.portal.GameMode.xml de xdg-desktop-portal) ;
# - MangoHud, Gamescope et vkBasalt, pour la session « Ankh Console » et les
#   applications hors Flatpak (les jeux en Flatpak ont leurs propres versions,
#   préparées avec l'option : /usr/libexec/ankh-flatpak) ;
# - les règles des manettes et casques de Steam (steam-devices), nécessaires à
#   Steam en Flatpak (wiki de https://github.com/flathub/com.valvesoftware.Steam).
# Sans l'option Gaming, ils restent à l'arrêt : gamemoded ne démarre qu'à la
# demande, et les couches Vulkan ne s'activent qu'avec leur variable
# (MANGOHUD=1, ENABLE_VKBASALT=1).
dnf5 -y install gamemode mangohud gamescope vkBasalt steam-devices
rpm -q gamemode mangohud gamescope vkBasalt steam-devices

# D-046 : options d'Ankh (Simple toujours incluse ; Dev, Gaming, Hacking ;
# Complète). Les entrées du menu de chaque option sont rangées hors du menu,
# dans /usr/share/ankh/options/<option>/applications, et
# /usr/libexec/ankh-options les rend visibles pour les options choisies ; de
# même pour la session « Ankh Console » de l'option Gaming (D-050), dans
# /usr/share/ankh/options/gaming/wayland-sessions.
# - ankh-options.service les remet en place à chaque démarrage ;
# - la page « Choisissez vos outils » de l'assistant de premier démarrage
#   démarre ankh-options@<choix>.service, autorisé au seul compte de
#   l'assistant (/usr/share/polkit-1/rules.d/50-ankh-options.rules) ;
# - « Options d'Ankh », dans la Configuration du système (catégorie
#   Système, dossier plasma/systemsettings/externalmodules lu par
#   app/kcmmetadatahelpers.h de https://invent.kde.org/plasma/systemsettings)
#   et dans le menu, permet de changer d'avis : une fenêtre aux mêmes cartes
#   que la page de l'assistant (widget org.ankh.options, ouvert par
#   plasmawindowed ; cartes du module QML org.ankh.composants), qui applique
#   le choix par pkexec avec le mot de passe d'un administrateur (action
#   polkit org.ankh.options.appliquer).
# Ce changement touche à polkit : à relire.
systemctl enable ankh-options.service
for f in /usr/share/applications/*.desktop; do
    case "$(basename "${f}")" in
        ankh-vscode.desktop | ankh-dev-*.desktop)
            echo "${f} : une entrée de l'option Dev est restée dans le menu" >&2
            exit 1
            ;;
    esac
done
# Une entrée d'option n'est jamais aussi dans le menu de toute installation
for f in /usr/share/ankh/options/*/applications/*.desktop; do
    if [[ -e "/usr/share/applications/$(basename "${f}")" ]]; then
        echo "${f} : cette entrée d'option est aussi dans /usr/share/applications" >&2
        exit 1
    fi
done
desktop-file-validate /usr/share/ankh/options/*/applications/*.desktop /usr/share/applications/ankh-options.desktop \
    /usr/share/applications/ai.storyteller.*.desktop /etc/xdg/autostart/ankh-craft-nouveautes.desktop
install -d -m 0755 /usr/share/plasma/systemsettings/externalmodules
ln -s /usr/share/applications/ankh-options.desktop /usr/share/plasma/systemsettings/externalmodules/ankh-options.desktop
# La page de l'assistant et la fenêtre des réglages lancent leurs commandes
# par le moteur « executable » de Plasma5Support (src/dataengines/executable
# de https://invent.kde.org/plasma/plasma5support). La fenêtre s'ouvre par
# plasmawindowed, applique le choix par pkexec, puis met à jour le menu
# (kbuildsycoca6) et la barre (busctl) de la session : tout doit être là.
moteur="$(find /usr/lib64/qt6/plugins -name 'plasma_engine_executable.so' -print -quit)"
if [[ -z "${moteur}" ]]; then
    echo "Moteur « executable » de Plasma5Support introuvable : options d'Ankh à revoir" >&2
    exit 1
fi
echo "Moteur « executable » : ${moteur} ($(rpm -qf "${moteur}"))"
test -d /usr/lib64/qt6/qml/org/kde/plasma/plasma5support
# L'option Gaming prépare ses applications par Flatpak dans une fenêtre
# Konsole, puis les ouvre par leur propre entrée du menu avec gio
# (/usr/libexec/ankh-flatpak), et sa session lance KWin seul
# (/usr/libexec/ankh-console).
for outil in plasmawindowed pkexec kbuildsycoca6 busctl flatpak konsole kwin_wayland gio; do
    if ! chemin="$(command -v "${outil}")"; then
        echo "${outil} introuvable : options d'Ankh à revoir" >&2
        exit 1
    fi
    paquet="$(rpm -qf "${chemin}")"
    echo "${outil} : ${chemin} (${paquet})"
done
# La fenêtre du mot de passe de pkexec : l'agent polkit de KDE
rpm -q polkit-kde

# D-053 : la suite Craft se prépare dans une fenêtre Konsole, qui suit le
# journal du service ankh-craft@<nom> (tail) ; le service télécharge le
# Flatpak (curl), vérifie son empreinte (sha256sum) et l'installe (flatpak).
# Une nouvelle version est proposée par une notification à boutons
# (notify-send de libnotify : --action et --wait).
dnf5 -y install libnotify
for outil in systemctl tail curl sha256sum notify-send; do
    if ! chemin="$(command -v "${outil}")"; then
        echo "${outil} introuvable : suite Craft à revoir" >&2
        exit 1
    fi
    echo "${outil} : ${chemin} ($(rpm -qf "${chemin}"))"
done
aide_notify="$(notify-send --help)"
grep -q -- '--action' <<< "${aide_notify}"
grep -q -- '--wait' <<< "${aide_notify}"

# D-033 : habillage Ankh, sur le bureau seulement (modifie D-001). Le logo et
# les fonds d'écran viennent de build_files/artwork et sont copiés juste au-dessus.
# Rien ne change au démarrage : l'écran de démarrage, le chargeur EFI signé
# et Secure Boot restent ceux de Fedora.
#
# Nom affiché « Ankh », dans « À propos de ce système » et dans le menu de
# démarrage : ostree écrit le titre de chaque entrée à partir de PRETTY_NAME
# (src/libostree/ostree-sysroot-deploy.c). ID reste « fedora » : des outils
# s'en servent pour reconnaître le système (Aurora, qui l'a changé, doit
# corriger grub2-switch-to-blscfg en retour).
if [[ "$(readlink -f /etc/os-release)" != "$(readlink -f /usr/lib/os-release)" ]]; then
    echo "/etc/os-release n'est pas un lien vers /usr/lib/os-release" >&2
    exit 1
fi
os_release="$(readlink -f /usr/lib/os-release)"
for key in NAME PRETTY_NAME LOGO HOME_URL ANSI_COLOR DEFAULT_HOSTNAME; do
    sed -i "/^${key}=/d" "${os_release}"
done
cat >> "${os_release}" << 'OSRELEASE'
NAME="Ankh"
PRETTY_NAME="Ankh"
LOGO=ankh-logo
HOME_URL="https://github.com/PatrickChoumi/Ankh"
ANSI_COLOR="0;38;2;167;139;250"
DEFAULT_HOSTNAME="ankh"
OSRELEASE
grep -qx 'ID=fedora' "${os_release}"
# D-034 (correction, vue sur les captures de la PR #9) : la variante
# « Kinoite » s'affichait dans « À propos de ce système ». VARIANT est retiré
# et VERSION ne garde que le numéro ; VARIANT_ID, lu par des outils, reste.
version_id="$(sed -n 's/^VERSION_ID=//p' "${os_release}" | tr -d '"')"
sed -i -e '/^VARIANT=/d' -e "s/^VERSION=.*/VERSION=\"${version_id}\"/" "${os_release}"
cat "${os_release}"

# Nom de machine par défaut : « ankh », pour toutes les machines (générique,
# D-021). DEFAULT_HOSTNAME ne suffit pas : l'initramfs de Fedora nomme déjà la
# machine « fedora », et systemd garde un nom existant si /etc/hostname est
# absent (src/shared/hostname-setup.c, hostname_setup ; vu en VM). Un
# changement fait avec hostnamectl reste local à la machine, comme tout /etc.
# Le fichier de la base, s'il existe, est vu tel quel grâce à
# « podman build --no-hostname » (Justfile).
if [[ -e /etc/hostname ]]; then
    echo "/etc/hostname existe déjà dans la base (« $(cat /etc/hostname) ») : réglage à fusionner à la main" >&2
    exit 1
fi
echo ankh > /etc/hostname

# VS Code dans le menu (D-036) : son icône officielle, tirée du pack que
# Microsoft publie pour représenter VS Code (https://code.visualstudio.com/brand,
# « Download the icons » ; version 2021-06-21 selon son README). L'archive
# est refusée si son empreinte change : une nouvelle version se regarde avant
# d'entrer dans l'image (D-043). Nom propre à Ankh, pour qu'aucun thème
# d'icônes ne la remplace.
vscode_icones=/tmp/visual-studio-code-icons.zip
curl -fsSL https://code.visualstudio.com/assets/branding/visual-studio-code-icons.zip -o "${vscode_icones}"
echo "04c5292a117bbc619f1ce574cc59b6c5e2e26374d6e64b92619e848612f2d9cb  ${vscode_icones}" | sha256sum -c -
python3 -c 'import sys, zipfile; sys.stdout.buffer.write(zipfile.ZipFile(sys.argv[1]).read("visual-studio-code-icons/vscode.svg"))' "${vscode_icones}" \
    > /usr/share/icons/hicolor/scalable/apps/ankh-vscode.svg
chmod 0644 /usr/share/icons/hicolor/scalable/apps/ankh-vscode.svg
rm "${vscode_icones}"

# Logo dans le thème d'icônes : le cache est refait, car ostree met la même
# date à tous les fichiers et un cache périmé paraîtrait encore valide.
gtk-update-icon-cache --force /usr/share/icons/hicolor

# Fond d'écran par défaut : celui du thème global (Plasma lit [Wallpaper]
# Image= dans son fichier defaults, plasma-workspace,
# wallpapers/defaultwallpaper.cpp). D'après le code de Plasma, le bureau,
# l'écran de verrouillage et l'écran de connexion le reprennent. Chaque thème
# global est réglé, pour garder le fond d'Ankh quel que soit le thème choisi.
# Le fond par défaut est « Ankh Signal », de la collection de D-034.
mapfile -t lnf_defaults < <(grep -l '^\[Wallpaper\]' /usr/share/plasma/look-and-feel/*/contents/defaults)
if [[ ${#lnf_defaults[@]} -eq 0 ]]; then
    echo "Aucun thème global ne règle le fond d'écran par défaut" >&2
    exit 1
fi
for f in "${lnf_defaults[@]}"; do
    echo "${f} : fond d'origine « $(sed -n '/^\[Wallpaper\]/,/^\[/ s/^Image=//p' "${f}") »"
    sed -i '/^\[Wallpaper\]/,/^\[/ s/^Image=.*/Image=Ankh-Signal/' "${f}"
done

# D-034 : plus rien de Fedora à l'écran, démarrage compris (complète D-033).
# Sous le capot, les paquets, le noyau et l'identifiant « fedora » restent.
#
# Logos : le paquet générique que Fedora fournit à ses dérivés remplace
# fedora-logos, comme le fait Aurora (build_scripts/base/01-packages.sh de
# https://github.com/ublue-os/aurora).
# Garde-fou : ce changement ne doit retirer aucun autre paquet.
avant="$(rpm -qa --qf '%{NAME}\n' | sort -u)"
dnf5 -y swap fedora-logos generic-logos
retires="$(comm -23 <(echo "${avant}") <(rpm -qa --qf '%{NAME}\n' | sort -u) | sed '/^fedora-logos$/d')"
if [[ -n "${retires}" ]]; then
    echo "Le changement de logos a aussi retiré : ${retires}" >&2
    exit 1
fi
# Le cache d'icônes est refait après ce changement de logos (voir D-033).
gtk-update-icon-cache --force /usr/share/icons/hicolor
echo "Images de generic-logos : $(rpm -ql generic-logos | grep -E '\.(png|svg)$' | tr '\n' ' ')"

# « À propos de ce système » lit son logo et sa variante dans
# kcm-about-distrorc, avant os-release. Le réglage de Fedora y désignait
# l'image de generic-logos (un hot-dog) et la variante « Kinoite » (vu sur les
# captures de la PR #9). Chaque fichier trouvé, et celui de /etc/xdg, désigne
# maintenant le logo d'Ankh, sans variante (build_files/regler-a-propos.py).
mapfile -t about_distro < <(find /etc/xdg /usr/share/kde-settings -name kcm-about-distrorc)
for f in /etc/xdg/kcm-about-distrorc "${about_distro[@]}"; do
    python3 /ctx/regler-a-propos.py "${f}"
done

# Le paquet flatpak de Fedora ajoute au premier démarrage le dépôt
# « Fedora Flatpaks », visible dans Discover. Il est masqué : les applications
# viennent de Flathub (D-011).
systemctl mask flatpak-add-fedora-repos.service

# Thèmes globaux de Fedora (paquet plasma-lookandfeel-fedora) : kde-settings-plasma
# en dépend et en règle un par défaut, ils restent donc. Ils deviennent les
# thèmes d'Ankh : nom, description et aperçus. Leurs écrans de démarrage de
# session n'affichent que les logos de KDE. Leur identifiant ne se voit pas.
for theme_nom in "fedora:Ankh" "fedoradark:Ankh Sombre" "fedoralight:Ankh Clair"; do
    dossier="/usr/share/plasma/look-and-feel/org.fedoraproject.${theme_nom%%:*}.desktop"
    python3 - "${dossier}/metadata.json" "${theme_nom#*:}" << 'PY'
import json
import sys

chemin, nom = sys.argv[1], sys.argv[2]
with open(chemin, encoding="utf-8") as f:
    fiche = json.load(f)
plugin = fiche["KPlugin"]
# Toute mention de Fedora disparaît, sauf l'identifiant, invisible.
for cle in list(plugin):
    if cle != "Id" and "fedora" in json.dumps(plugin[cle]).lower():
        del plugin[cle]
plugin["Name"] = nom
plugin["Description"] = "Thème global d'Ankh"
with open(chemin, "w", encoding="utf-8") as f:
    json.dump(fiche, f, indent=4, ensure_ascii=False)
    f.write("\n")
PY
    for apercu in preview.png fullscreenpreview.jpg lockscreen.png; do
        install -m 0644 "/usr/share/ankh/apercus/${apercu}" "${dossier}/contents/previews/${apercu}"
    done
done

# Fonds d'écran de Fedora : l'écran de verrouillage (kde-settings) et l'écran
# de connexion (Plasma Login) les désignent explicitement, sans passer par le
# fond par défaut du thème global (vu par le Test 11). Ils désignent
# maintenant « Ankh Signal », puis les fonds de Fedora sont retirés.
# kde-settings-plasma dépend de leur paquet, qui reste installé, sans images.
for f in /usr/share/kde-settings/kde-profile/default/xdg/kscreenlockerrc /usr/lib/plasmalogin/defaults.conf; do
    if ! grep -q 'wallpapers/Fedora/' "${f}"; then
        echo "${f} ne désigne plus le fond de Fedora : réglage à revoir" >&2
        exit 1
    fi
    sed -i 's|/usr/share/wallpapers/Fedora/|/usr/share/wallpapers/Ankh-Signal/|g' "${f}"
done
# « Fedora » et « Default » sont des liens vers le fond de la version (F44).
rm /usr/share/wallpapers/Fedora /usr/share/wallpapers/Default
rm -r /usr/share/wallpapers/F[0-9]*

# D-037 et D-039 : identité visuelle d'Ankh, validée sur les aperçus en VM le
# 2026-10-09 : sombre partout, graphite et violet, interface douce au niveau
# de Windows 11 et de macOS. Ce sont des réglages par défaut, pour chaque
# compte ; chacun reste modifiable dans les réglages de KDE. Le jeu de
# couleurs « Ankh » et le profil Konsole sont copiés plus haut
# (build_files/files).
#
# Polices de Fedora : JetBrains Mono pour le terminal et le code, Inter pour
# l'écran de connexion et l'écran de démarrage (D-043).
dnf5 -y install rsms-inter-fonts jetbrains-mono-fonts

# D-052, lot 1 : fondations de l'interface, aux mesures de Windows 11.
# - Police Selawik, le sosie libre de Segoe UI (OFL 1.1), compilée depuis ses
#   sources dans l'étape « outils » du Containerfile (build_files/outils.sh).
#   Texte courant de 14 px et légendes de 12 px, comme Windows
#   (BodyTextBlockFontSize et CaptionTextBlockFontSize de
#   CommonStyles/TextBlock_themeresources.xaml, WinUI) : 10,5 et 9 points à
#   96 points par pouce. Titre des fenêtres en légende (page
#   basics/titlebar-design de Microsoft). Ses glyphes couvrent le français,
#   sauf les espaces insécables (U+00A0, U+202F), prises dans une autre police
#   par fontconfig.
install -d -m 0755 /usr/share/fonts/selawik /usr/share/licenses/selawik
install -m 0644 /outils/polices/selawik/Selawik-*.ttf /usr/share/fonts/selawik/
install -m 0644 /outils/polices/selawik/OFL.txt /usr/share/licenses/selawik/OFL.txt
for graisse in Light Regular Bold; do
    if [[ "$(fc-scan --format '%{family[0]}:%{weight}' "/usr/share/fonts/selawik/Selawik-${graisse}.ttf")" != Selawik:* ]]; then
        echo "Selawik ${graisse} : fichier de police illisible" >&2
        exit 1
    fi
done
# Le cache de fontconfig du système, refait par dnf juste avant (polices
# Inter et JetBrains Mono), ne connaît pas Selawik. Dans l'image construite
# le 2026-10-16, fontconfig ne la trouvait pas, alors que ses fichiers y
# étaient (Test 14) : le cache est refait, et Selawik doit être trouvée par
# son nom.
fc-cache --system-only --really-force
famille="$(fc-match -f '%{family[0]}' Selawik)"
if [[ "${famille}" != Selawik ]]; then
    echo "fontconfig ne trouve pas Selawik (il propose « ${famille} »)" >&2
    exit 1
fi
# - Rendu des polices en niveaux de gris, contours légèrement ajustés
#   (hintslight), comme AnduinOS et les applications de Windows 11. Il est
#   décidé par fontconfig (/etc/fonts/conf.d/29-ankh-rendu.conf, copié plus
#   bas) : Qt (QFontconfigDatabase) prend sinon la disposition des
#   sous-pixels annoncée par l'écran, que KWin lit dans l'EDID. Le module
#   des polices de KDE lit lui aussi fontconfig (kcms/fonts/kxftconfig.cpp
#   de plasma-workspace) ; les réglages Xft de kdeglobals ne servent qu'aux
#   applications X11. Vérifié après la copie, plus bas.

# Thème global par défaut : « Ankh Sombre » (le thème sombre de Fedora, renommé
# plus haut). À chaque ouverture de session, Plasma applique les réglages par
# défaut du thème global choisi (startkde/startplasma.cpp de
# https://invent.kde.org/plasma/plasma-workspace). Son jeu de couleurs devient
# « Ankh ». La valeur d'origine est vérifiée : un changement dans la base doit
# se voir.
sombre=/usr/share/plasma/look-and-feel/org.fedoraproject.fedoradark.desktop
couleurs="$(kreadconfig6 --file "${sombre}/contents/defaults" --group kdeglobals --group General --key ColorScheme)"
if [[ "${couleurs}" != BreezeDark ]]; then
    echo "${sombre} : jeu de couleurs « ${couleurs} » au lieu de BreezeDark : réglage à revoir" >&2
    exit 1
fi
kwriteconfig6 --file "${sombre}/contents/defaults" --group kdeglobals --group General --key ColorScheme Ankh
# /etc/xdg/kdeglobals (créé plus haut, D-023) passe avant les réglages de Fedora
# (XDG_CONFIG_DIRS=/etc/xdg:/usr/share/kde-settings/kde-profile/default/xdg,
# plasma-workspace/env/env.sh du paquet kde-settings-plasma).
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key LookAndFeelPackage org.fedoraproject.fedoradark.desktop
# Polices, au format des réglages de Fedora (kde-profile/default/xdg/kdeglobals) :
# Selawik à 14 px (10,5 points) et 12 px (9 points), D-052 lot 1.
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key font 'Selawik,10.5,-1,5,50,0,0,0,0,0'
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key menuFont 'Selawik,10.5,-1,5,50,0,0,0,0,0'
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key toolBarFont 'Selawik,10.5,-1,5,50,0,0,0,0,0'
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key smallestReadableFont 'Selawik,9,-1,5,50,0,0,0,0,0'
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key fixed 'JetBrains Mono,10,-1,5,50,0,0,0,0,0'
kwriteconfig6 --file /etc/xdg/kdeglobals --group WM --key activeFont 'Selawik,9,-1,5,50,0,0,0,0,0'
# Rendu des polices décidé par fontconfig (voir plus haut) : rgba 5 (aucun
# sous-pixel), hintstyle 1 (léger)
rendu="$(fc-match -f '%{rgba} %{hintstyle} %{antialias}' Selawik)"
if [[ "${rendu}" != "5 1 True" ]]; then
    echo "Rendu des polices inattendu : « ${rendu} » (rgba, hintstyle, antialias)" >&2
    exit 1
fi
# Rendu des polices pour les applications X11 (voir plus haut)
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key XftAntialias true
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key XftHintStyle hintslight
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key XftSubPixel none
# D-052, lot 1 : durées des animations de Windows 11 (83, 167, 250 et 333 ms,
# page signature-experiences/motion de Microsoft). Celles de KDE (Kirigami :
# 50, 100, 200 et 400 ms ; effets de KWin) sont multipliées par ce facteur :
# 5/6 donne 42, 83, 167 et 333 ms.
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key AnimationDurationFactor 0.8333333
# D-054 : la couleur d'accent suit le fond d'écran, comme « Automatique » dans
# Windows 11 (accentColorFromWallpaper, faux par défaut :
# kcms/colors/colorssettings.kcfg de plasma-workspace). Les fonds d'Ankh
# désignent le violet d'Ankh dans leur metadata.json ; pour une autre image,
# Plasma prend sa couleur dominante.
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key accentColorFromWallpaper true

# D-052, lot 4 : notifications en bas à droite, au-dessus de la barre, comme
# Windows 11 (PopupPosition, CloseToWidget par défaut :
# libnotificationmanager/kcfg/notificationsettings.kcfg de plasma-workspace)
kwriteconfig6 --file /etc/xdg/plasmanotifyrc --group Notifications --key PopupPosition BottomRight

# Barre collée en bas, de 48 px, menu et applications au centre (build_files/plasma/ankh-barre.js),
# et écran de chargement de la session d'Ankh (build_files/plasma/ankh-splash.qml),
# dans tous les thèmes globaux : ceux de Fedora (renommés « Ankh ») et ceux de
# KDE (Breeze). L'assistant de premier démarrage applique un thème Breeze si
# l'on touche à son choix clair/sombre (D-037) ; Ankh garde alors sa barre et
# son écran de chargement. Les thèmes sans écran de chargement à eux désignent
# celui de Breeze, devenu celui d'Ankh. Les fichiers partagés entre thèmes sont
# remplacés dans chacun.
mapfile -t themes < <(find /usr/share/plasma/look-and-feel -mindepth 1 -maxdepth 1 -type d | sort)
for attendu in org.fedoraproject.fedora.desktop org.fedoraproject.fedoradark.desktop \
    org.fedoraproject.fedoralight.desktop org.kde.breeze.desktop org.kde.breezedark.desktop; do
    if [[ ! -d "/usr/share/plasma/look-and-feel/${attendu}" ]]; then
        echo "Thème global ${attendu} absent : intégration à revoir" >&2
        exit 1
    fi
done
for dossier in "${themes[@]}"; do
    barre="${dossier}/contents/layouts/org.kde.plasma.desktop-layout.js"
    if [[ -e "${barre}" ]]; then
        rm "${barre}"
        install -m 0644 /ctx/plasma/ankh-barre.js "${barre}"
        echo "Barre d'Ankh : $(basename "${dossier}")"
    fi
    if [[ -e "${dossier}/contents/splash/Splash.qml" ]]; then
        rm "${dossier}/contents/splash/Splash.qml"
        install -m 0644 /ctx/plasma/ankh-splash.qml "${dossier}/contents/splash/Splash.qml"
        install -m 0644 /usr/share/icons/hicolor/scalable/apps/ankh-logo.svg "${dossier}/contents/splash/images/ankh-logo.svg"
        echo "Écran de chargement d'Ankh : $(basename "${dossier}")"
    fi
    # D-052, lot 7c : écran de déconnexion au dessin de la connexion d'Ankh
    # (build_files/plasma/adapter-deconnexion.py, vérifié dans l'étape
    # « outils » par verifier-deconnexion.sh) ; ses actions restent celles de KDE
    if [[ -e "${dossier}/contents/logout/Logout.qml" ]]; then
        deconnexion="$(mktemp)"
        cp "${dossier}/contents/logout/Logout.qml" "${deconnexion}"
        python3 /ctx/plasma/adapter-deconnexion.py "${deconnexion}"
        rm "${dossier}/contents/logout/Logout.qml" "${dossier}/contents/logout/LogoutButton.qml"
        install -m 0644 "${deconnexion}" "${dossier}/contents/logout/Logout.qml"
        install -m 0644 /ctx/plasma/deconnexion/LogoutButton.qml "${dossier}/contents/logout/LogoutButton.qml"
        rm "${deconnexion}"
        echo "Écran de déconnexion d'Ankh : $(basename "${dossier}")"
    fi
done
# Chaque thème de Fedora désigne son propre écran de chargement, devenu celui
# d'Ankh ; Fedora y désignait celui de KDE (ksplashrc dans contents/defaults ;
# setSplashScreen, libklookandfeel/klookandfeelmanager.cpp de plasma-workspace).
for theme in fedora fedoradark fedoralight; do
    dossier="/usr/share/plasma/look-and-feel/org.fedoraproject.${theme}.desktop"
    kwriteconfig6 --file "${dossier}/contents/defaults" --group ksplashrc --group KSplash --key Theme "org.fedoraproject.${theme}.desktop"
    chmod 0644 "${dossier}/contents/defaults"
done
# « Breeze sombre » de KDE prend aussi le jeu de couleurs d'Ankh : c'est le
# thème qu'applique l'assistant de premier démarrage pour « Dark Theme »
# (modules/prepareutil/prepareutil.cpp de plasma-setup).
brise_sombre=/usr/share/plasma/look-and-feel/org.kde.breezedark.desktop/contents/defaults
couleurs="$(kreadconfig6 --file "${brise_sombre}" --group kdeglobals --group General --key ColorScheme)"
if [[ "${couleurs}" != BreezeDark ]]; then
    echo "${brise_sombre} : jeu de couleurs « ${couleurs} » au lieu de BreezeDark : réglage à revoir" >&2
    exit 1
fi
kwriteconfig6 --file "${brise_sombre}" --group kdeglobals --group General --key ColorScheme Ankh
chmod 0644 "${brise_sombre}"

# D-052, lot 1 : curseurs blancs d'Ankh, à la taille de Plasma (24) : les
# curseurs Fluent blancs, à l'anneau d'attente violet, compilés dans l'étape
# « outils » du Containerfile (build_files/outils.sh). Chaque thème global
# désigne son curseur (kcminputrc, groupe Mouse, dans contents/defaults),
# que Plasma recopie à chaque session dans ~/.config/kdedefaults, avant
# /etc/xdg : le curseur d'Ankh y est donc écrit aussi.
cp -a --no-preserve=ownership /outils/icones/Ankh-curseurs /usr/share/icons/Ankh-curseurs
for curseur in default left_ptr pointer text wait progress; do
    if [[ ! -e "/usr/share/icons/Ankh-curseurs/cursors/${curseur}" ]]; then
        echo "Curseur « ${curseur} » absent des curseurs d'Ankh" >&2
        exit 1
    fi
done
kwriteconfig6 --file /etc/xdg/kcminputrc --group Mouse --key cursorTheme Ankh-curseurs
kwriteconfig6 --file /etc/xdg/kcminputrc --group Mouse --key cursorSize 24
for dossier in "${themes[@]}"; do
    if [[ -e "${dossier}/contents/defaults" ]]; then
        avant="$(kreadconfig6 --file "${dossier}/contents/defaults" --group kcminputrc --group Mouse --key cursorTheme)"
        kwriteconfig6 --file "${dossier}/contents/defaults" --group kcminputrc --group Mouse --key cursorTheme Ankh-curseurs
        chmod 0644 "${dossier}/contents/defaults"
        echo "Curseur d'Ankh : $(basename "${dossier}") (au lieu de « ${avant:-aucun} »)"
    fi
done

# D-052, lot 2 : décoration des fenêtres d'Ankh, aux mesures de Windows 11 :
# barre de titre de 32 px de la couleur de la fenêtre, icône et titre à
# gauche, boutons de 46×32 (Fermer rouge #C42B1C au survol), coins de 8 px,
# contour de 1 px, ombre de Windows. Dérivée de celle de Breeze, ses sources
# sont dans build_files/decoration ; compilée dans l'étape « outils » du
# Containerfile (build_files/outils.sh).
plugins_decoration=/usr/lib64/qt6/plugins/org.kde.kdecoration3
test -f "${plugins_decoration}/org.kde.breeze.so"
install -m 0755 /outils/decoration/org.ankh.decoration.so "${plugins_decoration}/org.ankh.decoration.so"
# Compilée avec les en-têtes du moment : toutes ses bibliothèques, et chacun
# de leurs symboles, doivent exister dans l'image. Un échec de ldd lui-même
# (fichier illisible ou pas une bibliothèque) arrête aussi la construction.
if ! liens="$(ldd -r "${plugins_decoration}/org.ankh.decoration.so" 2>&1)" \
    || grep -E 'not found|undefined symbol' <<< "${liens}"; then
    printf '%s\n' "${liens}" >&2
    echo "La décoration d'Ankh ne trouve pas ses bibliothèques dans l'image" >&2
    exit 1
fi
echo "Décoration d'Ankh : $(grep -c '=>' <<< "${liens}") bibliothèques trouvées ; kdecoration $(rpm -q --qf '%{VERSION}-%{RELEASE}' kdecoration)"
# Réglages de KWin (src/kcms/decoration/kwindecorationsettings.kcfg) : la
# décoration d'Ankh, son icône à gauche, réduire, agrandir et fermer à
# droite, sans bords (elle n'en dessine aucun)
kwriteconfig6 --file /etc/xdg/kwinrc --group org.kde.kdecoration2 --key library org.ankh.decoration
kwriteconfig6 --file /etc/xdg/kwinrc --group org.kde.kdecoration2 --key theme --delete
kwriteconfig6 --file /etc/xdg/kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft M
kwriteconfig6 --file /etc/xdg/kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight IAX
kwriteconfig6 --file /etc/xdg/kwinrc --group org.kde.kdecoration2 --key BorderSize None
kwriteconfig6 --file /etc/xdg/kwinrc --group org.kde.kdecoration2 --key BorderSizeAuto false
# D-052, lot 7a : Alt+Tab d'Ankh (paquet KWin/WindowSwitcher, posé avec les
# fichiers de build_files/files dans /usr/share/kwin-wayland/tabbox), et pas
# de mise en avant de la fenêtre choisie (les autres ne s'effacent pas,
# comme dans Windows 11) : [TabBox], src/tabbox/tabbox.cpp de KWin
test -f /usr/share/kwin-wayland/tabbox/org.ankh.alttab/contents/ui/main.qml
kwriteconfig6 --file /etc/xdg/kwinrc --group TabBox --key LayoutName org.ankh.alttab
kwriteconfig6 --file /etc/xdg/kwinrc --group TabBox --key HighlightWindows --type bool false
# D-052, lot 7b : vue des tâches d'Ankh (effet KWin/Effect écrit en QML, posé
# dans /usr/share/kwin-wayland/effects), allumée ([Plugins],
# src/effect/effectloader.cpp de KWin). Le bouton « Vue des tâches » de la
# barre l'ouvre ; les raccourcis de KDE ne changent pas (mon choix du
# 2026-10-23).
test -f /usr/share/kwin-wayland/effects/org.ankh.vuetaches/contents/ui/main.qml
test -f /usr/share/plasma/plasmoids/org.ankh.vuetaches/contents/ui/main.qml
kwriteconfig6 --file /etc/xdg/kwinrc --group Plugins --key org.ankh.vuetachesEnabled --type bool true
chmod 0644 /etc/xdg/kwinrc

# D-052, lot 7d : sons de KDE (thème Océan) réduits aux événements où
# Windows 11 joue un son (mon choix du 2026-10-23) : connexion, branchement
# d'un appareil, erreurs, minuteur, batterie faible. Les autres se taisent.
# KNotifications lit /etc/xdg/<application>.notifyrc avant les valeurs de
# KDE, et « None » coupe l'événement (src/knotifyconfig.cpp et
# src/knotificationmanager.cpp de KNotifications 6) ; chaque événement doit
# exister chez KDE, sinon le réglage serait sans effet : la construction
# échoue.
evenement_son() { # $1 : application, $2 : événement, $3 : actions
    if ! grep -qxF "[Event/$2]" "/usr/share/knotifications6/$1.notifyrc"; then
        echo "Sons d'Ankh : l'événement « $2 » n'existe plus dans $1.notifyrc" >&2
        exit 1
    fi
    kwriteconfig6 --file "/etc/xdg/$1.notifyrc" --group "Event/$2" --key Action "$3"
    chmod 0644 "/etc/xdg/$1.notifyrc"
}
# Connexion : le son d'ouverture de session (desktop-login), joué par
# plasma-startup-sound (startkde/startup-sound de plasma-workspace) ; KDE ne
# le joue pas par défaut
evenement_son plasma_workspace startkde Sound
# Coupés : corbeille vidée, avertissements, informations, questions, bip,
# demande de mot de passe, chargeur branché ou débranché ; les fenêtres et
# les bulles restent
evenement_son plasma_workspace "Trash: emptied" None
evenement_son plasma_workspace warning Popup
evenement_son plasma_workspace messageInformation Taskbar
evenement_son plasma_workspace messageWarning Taskbar
evenement_son plasma_workspace messageQuestion Taskbar
evenement_son plasma_workspace beep None
evenement_son polkit-kde-authentication-agent-1 authenticate None
evenement_son powerdevil pluggedin None
evenement_son powerdevil unplugged None
# Chaque thème global désigne aussi sa décoration (kwinrc, dans
# contents/defaults), recopiée à chaque session avant /etc/xdg, comme le
# curseur plus haut
for dossier in "${themes[@]}"; do
    defauts="${dossier}/contents/defaults"
    if [[ -e "${defauts}" ]]; then
        avant="$(kreadconfig6 --file "${defauts}" --group kwinrc --group org.kde.kdecoration2 --key library)"
        kwriteconfig6 --file "${defauts}" --group kwinrc --group org.kde.kdecoration2 --key library org.ankh.decoration
        kwriteconfig6 --file "${defauts}" --group kwinrc --group org.kde.kdecoration2 --key theme --delete
        # Alt+Tab d'Ankh aussi quand on applique le thème
        # (libklookandfeel/klookandfeelmanager.cpp : [kwinrc][WindowSwitcher])
        kwriteconfig6 --file "${defauts}" --group kwinrc --group WindowSwitcher --key LayoutName org.ankh.alttab
        chmod 0644 "${defauts}"
        echo "Décoration d'Ankh : $(basename "${dossier}") (au lieu de « ${avant:-aucune} »)"
    fi
done

# D-052, lot 3 : style des contrôles d'Ankh, aux mesures et au dessin des
# contrôles de Windows 11 (coins de 4, hauteur de 32, cases et boutons radio
# remplis de la couleur d'accent, bouton principal d'accent…). Dérivé de
# celui de Breeze, ses sources sont dans build_files/style ; compilé dans
# l'étape « outils » du Containerfile (build_files/outils.sh).
plugins_styles=/usr/lib64/qt6/plugins/styles
test -f "${plugins_styles}/breeze6.so"
install -m 0755 /outils/style/ankh6.so "${plugins_styles}/ankh6.so"
install -m 0644 /outils/style/ankh.themerc /usr/share/kstyle/themes/ankh.themerc
# Comme la décoration : bibliothèques et symboles présents, ldd réussi
if ! liens="$(ldd -r "${plugins_styles}/ankh6.so" 2>&1)" \
    || grep -E 'not found|undefined symbol' <<< "${liens}"; then
    printf '%s\n' "${liens}" >&2
    echo "Le style d'Ankh ne trouve pas ses bibliothèques dans l'image" >&2
    exit 1
fi
echo "Style d'Ankh : $(grep -c '=>' <<< "${liens}") bibliothèques trouvées"
# Style des applications (widgetStyle, kconfigwidgets/src/kstylemanager.cpp de
# KDE), aussi dans chaque thème global, dont les réglages sont recopiés à
# chaque session avant /etc/xdg
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key widgetStyle Ankh
for dossier in "${themes[@]}"; do
    defauts="${dossier}/contents/defaults"
    if [[ -e "${defauts}" ]]; then
        avant="$(kreadconfig6 --file "${defauts}" --group kdeglobals --group KDE --key widgetStyle)"
        kwriteconfig6 --file "${defauts}" --group kdeglobals --group KDE --key widgetStyle Ankh
        chmod 0644 "${defauts}"
        echo "Style d'Ankh : $(basename "${dossier}") (au lieu de « ${avant:-aucun} »)"
    fi
done

# D-052, lot 3 : les contrôles écrits en QML dans le style QtQuick de KDE
# (org.kde.desktop, qqc2-desktop-style), aux mesures de Windows 11 :
# interrupteur de 40×20, case de 32, élément de liste de 40, infobulle de
# 12 px, bouton mis en avant rempli d'accent. Le script vérifie chaque texte
# qu'il remplace et échoue si KDE l'a changé (build_files/qqc2/adapter.py).
python3 /ctx/qqc2/adapter.py /usr/lib64/qt6/qml/org/kde/desktop /ctx/qqc2/SwitchIndicator.qml
echo "Style QtQuick de KDE adapté : kf6-qqc2-desktop-style $(rpm -q --qf '%{VERSION}-%{RELEASE}' kf6-qqc2-desktop-style)"

# D-052, lot 4 : style Plasma « Ankh » (volets et menus aux coins de 8, barre
# translucide, boutons de la barre des tâches et infobulles de Windows 11).
# Ses SVG sont écrits ici depuis ceux de Breeze installés dans l'image, dont
# ils gardent les ombres (build_files/plasma/style-ankh.py) ; le reste vient
# de Breeze (FallbackTheme). Choisi par défaut, et dans chaque thème global,
# dont les réglages passent avant /etc/xdg quand on en applique un.
style_plasma=/usr/share/plasma/desktoptheme/ankh
test -f "${style_plasma}/metadata.json"
test -f /usr/share/plasma/desktoptheme/default/dialogs/background.svgz
python3 /ctx/plasma/style-ankh.py /usr/share/plasma/desktoptheme/default "${style_plasma}"
chmod -R u=rwX,go=rX "${style_plasma}"
kwriteconfig6 --file /etc/xdg/plasmarc --group Theme --key name ankh
for dossier in "${themes[@]}"; do
    defauts="${dossier}/contents/defaults"
    if [[ -e "${defauts}" ]]; then
        avant="$(kreadconfig6 --file "${defauts}" --group plasmarc --group Theme --key name)"
        kwriteconfig6 --file "${defauts}" --group plasmarc --group Theme --key name ankh
        chmod 0644 "${defauts}"
        echo "Style Plasma d'Ankh : $(basename "${dossier}") (au lieu de « ${avant:-aucun} »)"
    fi
done

# D-052, lot 4 : volets de la barre flottants, à 12 px de la barre, avec leurs
# quatre coins (mon choix du 2026-10-22, build_files/plasma/adapter-plasma.py) ;
# lot 7c : écran de verrouillage au dessin de la connexion d'Ankh (mon choix
# du 2026-10-23), son horloge posée avec les fichiers de l'image
coque=/usr/share/plasma/shells/org.kde.plasma.desktop
test -f "${coque}/contents/lockscreen/HorlogeAnkh.qml"
python3 /ctx/plasma/adapter-plasma.py "${coque}"
echo "Coque de Plasma adaptée : plasma-desktop $(rpm -q --qf '%{VERSION}-%{RELEASE}' plasma-desktop)"

# D-052, lot 3 : thème GTK Fluent au violet d'Ankh (mon choix du 2026-10-15,
# confirmé le 2026-10-21), construit dans l'étape « outils ». Clair, avec sa
# feuille sombre, prise quand KDE demande le sombre.
test ! -e /usr/share/themes/Fluent-Ankh
cp -r /outils/themes/Fluent-Ankh /usr/share/themes/Fluent-Ankh
chmod -R u=rwX,go=rX /usr/share/themes/Fluent-Ankh
# Thème des nouveaux comptes. KDE ne l'écrit qu'une fois, à la première
# session, et seulement s'il est vide (Breeze sinon : kconf_update/gtktheme.cpp
# de kde-gtk-config) ; il ne le change ensuite qu'à un choix fait dans les
# réglages. Sous Wayland, GTK 3 le lit aussi dans les réglages de GNOME
# (org.gnome.desktop.interface gtk-theme), dont la valeur par défaut devient
# celle d'Ankh.
for version in 3.0 4.0; do
    install -d -m 0755 "/etc/skel/.config/gtk-${version}"
    printf '[Settings]\ngtk-theme-name=Fluent-Ankh\n' > "/etc/skel/.config/gtk-${version}/settings.ini"
    chmod 0644 "/etc/skel/.config/gtk-${version}/settings.ini"
done
printf 'gtk-theme-name="Fluent-Ankh"\n' > /etc/skel/.gtkrc-2.0
chmod 0644 /etc/skel/.gtkrc-2.0
test -f /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml
printf "[org.gnome.desktop.interface]\ngtk-theme='Fluent-Ankh'\n" > /usr/share/glib-2.0/schemas/90_ankh.gschema.override
glib-compile-schemas --strict /usr/share/glib-2.0/schemas
theme_gtk="$(GSETTINGS_BACKEND=memory gsettings get org.gnome.desktop.interface gtk-theme)"
if [[ "${theme_gtk}" != "'Fluent-Ankh'" ]]; then
    echo "Thème GTK par défaut : ${theme_gtk} au lieu de 'Fluent-Ankh'" >&2
    exit 1
fi
echo "Thème GTK par défaut : ${theme_gtk}"

# Assistant de premier démarrage (D-037) : son fond est cherché dans le fond
# d'écran « Next » de KDE (src/qml/LandingComponent.qml de plasma-setup).
# Le fond d'Ankh y est mis, aux noms attendus
# (build_files/files/usr/share/ankh/assistant, tirés d'« Ankh Signal »).
# Ce dossier n'est pas proposé comme fond d'écran : sans fichier de
# description, ce n'est pas un paquet, et les images rangées sous
# contents/images, comme les liens, sont ignorées (wallpapers/image/plugin/finder,
# packagefinder.cpp et imagefinder.cpp de plasma-workspace).
# Le fond « Next » de KDE est arrivé dans la base le 2026-10-10, avec le
# paquet plasma-breeze-common de Fedora 44 (vu par la construction de la CI,
# arrêtée par cette vérification). Il est retiré comme les fonds de Fedora
# plus haut : aucun thème global ne le désigne plus (fond « Ankh Signal »),
# et les fonds proposés restent ceux d'Ankh. S'il vient d'un autre paquet, la
# construction s'arrête pour qu'on regarde.
if [[ -e /usr/share/wallpapers/Next ]]; then
    proprietaire="$(rpm -qf --qf '%{NAME}\n' /usr/share/wallpapers/Next | sort -u)"
    if [[ "${proprietaire}" != plasma-breeze-common ]]; then
        echo "/usr/share/wallpapers/Next vient de « ${proprietaire} » : fond de l'assistant à revoir" >&2
        exit 1
    fi
    echo "Fond « Next » de KDE (${proprietaire}) retiré, remplacé par celui de l'assistant d'Ankh :"
    find /usr/share/wallpapers/Next -type f
    rm -r /usr/share/wallpapers/Next
fi
# Dans les deux dossiers : en thème sombre, l'assistant cherche dans
# images_dark, et son repli vers images ne marche pas (fond resté uni sur les
# captures de la VM du 2026-10-10, PR #12).
for dossier in images images_dark; do
    install -d -m 0755 "/usr/share/wallpapers/Next/contents/${dossier}"
    ln -s /usr/share/ankh/assistant/5120x2880.png "/usr/share/wallpapers/Next/contents/${dossier}/5120x2880.png"
    ln -s /usr/share/ankh/assistant/1080x1920.png "/usr/share/wallpapers/Next/contents/${dossier}/1080x1920.png"
done
# Sa page « Bienvenue dans Ankh » est un module ajouté par la méthode prévue
# par KDE (docs/CUSTOM_MODULES.md de plasma-setup), copié plus haut
# (build_files/files/usr/share/plasma/packages/org.ankh.plasmasetup.bienvenue).

# Breeze plus doux : menus translucides et floutés (MenuOpacity, flou demandé
# par kstyle/breezestyle.cpp et breezeblurhelper.cpp), ombres des fenêtres
# plus grandes et plus légères (kdecoration/breezesettingsdata.kcfg de
# https://invent.kde.org/plasma/breeze).
if [[ -e /etc/xdg/breezerc ]]; then
    echo "/etc/xdg/breezerc existe déjà dans la base : réglage à fusionner à la main" >&2
    exit 1
fi
kwriteconfig6 --file /etc/xdg/breezerc --group Style --key MenuOpacity 85
kwriteconfig6 --file /etc/xdg/breezerc --group Common --key ShadowSize ShadowVeryLarge
kwriteconfig6 --file /etc/xdg/breezerc --group Common --key ShadowStrength 160
# Le style d'Ankh (D-052, lot 3) lit les mêmes réglages dans ankhrc
if [[ -e /etc/xdg/ankhrc ]]; then
    echo "/etc/xdg/ankhrc existe déjà dans la base : réglage à fusionner à la main" >&2
    exit 1
fi
kwriteconfig6 --file /etc/xdg/ankhrc --group Style --key MenuOpacity 85
kwriteconfig6 --file /etc/xdg/ankhrc --group Common --key ShadowSize ShadowVeryLarge
kwriteconfig6 --file /etc/xdg/ankhrc --group Common --key ShadowStrength 160
# Konsole s'ouvre avec le profil Ankh. /etc/xdg/konsolerc vient du paquet
# konsole-part de Fedora (barre de menus masquée, historique) : il est gardé,
# le profil par défaut y est seulement ajouté, s'il n'en fixe pas déjà un.
if [[ -e /etc/xdg/konsolerc ]]; then
    echo "/etc/xdg/konsolerc de la base ($(rpm -qf /etc/xdg/konsolerc)), gardé :"
    cat /etc/xdg/konsolerc
    profil="$(kreadconfig6 --file /etc/xdg/konsolerc --group 'Desktop Entry' --key DefaultProfile)"
    if [[ -n "${profil}" ]]; then
        echo "/etc/xdg/konsolerc fixe déjà le profil « ${profil} » : réglage à fusionner à la main" >&2
        exit 1
    fi
fi
kwriteconfig6 --file /etc/xdg/konsolerc --group 'Desktop Entry' --key DefaultProfile Ankh.profile
# Lisibles par tous les comptes : KConfig peut créer ses fichiers pour leur
# seul propriétaire (root ici).
chmod 0644 /etc/xdg/kdeglobals /etc/xdg/breezerc /etc/xdg/ankhrc /etc/xdg/konsolerc "${sombre}/contents/defaults"

# Le premier terminal n'affiche plus le message de Fedora qui conseille Toolbx
# et DNF (contraire à D-009 et D-036). /etc/profile.d/toolbox.sh (paquet
# toolbox) ne l'affiche pas si ~/.config/toolbox/host-welcome-shown existe :
# chaque nouveau compte reçoit ce fichier vide de /etc/skel (build_files/files).
if ! grep -q 'host-welcome-shown' /etc/profile.d/toolbox.sh; then
    echo "/etc/profile.d/toolbox.sh ne lit plus host-welcome-shown : message de bienvenue à revoir" >&2
    exit 1
fi

# D-042 : finitions au niveau de macOS et de Windows 11 (complète D-039).
# Toujours des réglages par défaut de KDE, modifiables par chaque compte ;
# la construction échoue si la base fixe déjà l'un d'eux.
#
# Thèmes clairs aux couleurs d'Ankh : chaque thème global qui prend Breeze
# clair (« Ankh », « Ankh Clair », Breeze clair de KDE…) prend le jeu « Ankh
# Clair » (build_files/files/usr/share/color-schemes/AnkhClair.colors).
clairs=()
for dossier in "${themes[@]}"; do
    reglages="${dossier}/contents/defaults"
    if [[ -e "${reglages}" && "$(kreadconfig6 --file "${reglages}" --group kdeglobals --group General --key ColorScheme)" == BreezeLight ]]; then
        kwriteconfig6 --file "${reglages}" --group kdeglobals --group General --key ColorScheme AnkhClair
        chmod 0644 "${reglages}"
        clairs+=("$(basename "${dossier}")")
    fi
done
echo "Jeu de couleurs « Ankh Clair » : ${clairs[*]}"
for attendu in org.fedoraproject.fedora.desktop org.fedoraproject.fedoralight.desktop org.kde.breeze.desktop; do
    if [[ " ${clairs[*]} " != *" ${attendu} "* ]]; then
        echo "${attendu} ne prenait pas Breeze clair : jeu de couleurs clair à revoir" >&2
        exit 1
    fi
done
# Clair et sombre automatiques (selon l'heure, comme sous macOS), si je
# l'active dans les réglages du thème global : entre « Ankh Clair » et « Ankh
# Sombre », au lieu de Breeze (DefaultLightLookAndFeel et
# DefaultDarkLookAndFeel de kcms/lookandfeel/lookandfeelsettings.kcfg,
# https://invent.kde.org/plasma/plasma-workspace).
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key DefaultLightLookAndFeel org.fedoraproject.fedoralight.desktop
kwriteconfig6 --file /etc/xdg/kdeglobals --group KDE --key DefaultDarkLookAndFeel org.fedoraproject.fedoradark.desktop

# Recherche (Alt+Espace) au milieu de l'écran, comme Spotlight sous macOS,
# au lieu d'un bandeau collé en haut : réglage FreeFloating de KRunner
# (krunner/view.cpp de plasma-workspace : fenêtre posée au tiers de la
# hauteur de l'écran).
for f in /etc/xdg/krunnerrc /usr/share/kde-settings/kde-profile/default/xdg/krunnerrc; do
    if [[ -e "${f}" ]]; then
        echo "${f} existe déjà dans la base : réglage de la recherche à fusionner à la main" >&2
        exit 1
    fi
done
kwriteconfig6 --file /etc/xdg/krunnerrc --group General --key FreeFloating true

# Favoris du menu : les applications d'Ankh, au lieu de celles de Fedora
# (KWrite, Kontact). Le menu les lit dans kicker-extra-favoritesrc à sa
# création pour chaque compte (portOldFavorites, applets/kicker/kastatsfavoritesmodel.cpp
# de plasma-workspace) ; /etc/xdg passe avant le fichier de Fedora
# (kde-profile/default/xdg/kicker-extra-favoritesrc, paquet kde-settings).
# Les applications épinglées dans la barre sont dans ankh-barre.js.
if [[ -e /etc/xdg/kicker-extra-favoritesrc ]]; then
    echo "/etc/xdg/kicker-extra-favoritesrc existe déjà dans la base : favoris à fusionner à la main" >&2
    exit 1
fi
favoris=(preferred://browser ankh-vscode.desktop org.kde.dolphin.desktop org.kde.konsole.desktop
    org.kde.discover.desktop "$(basename "${vlc_lanceur}")" ai.storyteller.wordcraft.desktop systemsettings.desktop)
# Un favori peut venir d'une option (D-046) : il n'apparaît alors que si
# l'option est choisie.
for favori in "${favoris[@]}"; do
    if [[ "${favori}" == *.desktop && ! -e "/usr/share/applications/${favori}" ]] &&
        ! compgen -G "/usr/share/ankh/options/*/applications/${favori}" > /dev/null; then
        echo "Favori du menu introuvable : ${favori}" >&2
        exit 1
    fi
done
kwriteconfig6 --file /etc/xdg/kicker-extra-favoritesrc --group General --key Prepend "$(IFS=';'; echo "${favoris[*]}")"
kwriteconfig6 --file /etc/xdg/kicker-extra-favoritesrc --group General --key IgnoreDefaults true

# Accueil de KDE (Welcome Center), ouvert à la première session : texte et
# logo d'Ankh sur sa première page, et une page « Raccourcis utiles », par
# les fichiers prévus par KDE (README.md de https://invent.kde.org/plasma/plasma-welcome),
# copiés plus haut (build_files/files/usr/share/plasma/plasma-welcome).
# Le paquet de Fedora qui fait la même chose pour Fedora est absent (Test 11).
rpm -q plasma-welcome
if ! grep -q 'Bienvenue dans Ankh' /usr/share/plasma/plasma-welcome/intro-customization.desktop; then
    echo "Première page de l'accueil de KDE : ce n'est pas celle d'Ankh" >&2
    exit 1
fi

chmod 0644 /etc/xdg/kdeglobals /etc/xdg/krunnerrc /etc/xdg/kicker-extra-favoritesrc

# Écran de connexion et de verrouillage d'Ankh (ma demande du 2026-10-10) :
# le gestionnaire de connexion de KDE (Plasma Login) dessine son écran dans
# son propre programme (src/frontend/greeter/main.cpp de
# https://invent.kde.org/plasma/plasma-login-manager : Main.qml compilé) ;
# il prend le fond d'écran d'Ankh (plus haut), le jeu de couleurs et les
# polices du thème global (src/frontend/startkde/startplasma.cpp). Il manque
# l'image du compte : sans image, c'est la silhouette de KDE. Chaque nouveau
# compte reçoit celle d'Ankh (build_files/artwork/generer.py), enregistrée
# pour l'écran de connexion à la première session
# (build_files/files/usr/libexec/ankh-image-de-compte et son lancement
# automatique dans /etc/xdg/autostart).
if [[ -e /etc/skel/.face.icon ]]; then
    echo "/etc/skel/.face.icon existe déjà dans la base : image de compte à revoir" >&2
    exit 1
fi
install -m 0644 /usr/share/ankh/avatar.png /etc/skel/.face.icon

# D-043 : écran de connexion entièrement dessiné pour Ankh (mon choix du
# 2026-10-10), avec SDDM au lieu de Plasma Login, dont l'écran ne se change
# pas. SDDM 0.21 de Fedora 44 charge un thème en QML, Qt 6
# (build_files/files/usr/share/sddm/themes/ankh) ; son écran d'accueil
# tourne sous Wayland, dans KWin (paquet sddm-wayland-plasma, fichier
# /usr/lib/sddm/sddm.conf.d/plasma-wayland.conf). L'assistant de premier
# démarrage sait travailler avec SDDM : il y écrit sa connexion automatique
# dès que Plasma Login n'est pas activé (src/bootutil/bootutil.cpp de
# https://invent.kde.org/plasma/plasma-setup).
# Ce changement touche au démarrage de la session graphique : à relire.
dnf5 -y install sddm sddm-wayland-plasma
# Plasma Login et sa page des réglages (qui ne réglerait plus rien) sont
# retirés, s'ils sont dans la base. La liste de ce qui part est affichée.
mapfile -t plasma_login < <(rpm -q --qf '%{NAME}\n' plasma-login-manager kcm-plasmalogin | grep -v 'not installed')
if [[ ${#plasma_login[@]} -gt 0 ]]; then
    dnf5 -y remove "${plasma_login[@]}"
fi
for p in sddm sddm-wayland-plasma plasma-workspace plasma-setup; do
    rpm -q "${p}"
done
# L'écran d'accueil de SDDM est lancé dans KWin par le réglage de
# sddm-wayland-plasma : ce réglage et le programme de KWin doivent exister.
# Le nom du paquet de KWin n'est pas vérifié ici, seulement le programme.
grep -H '^CompositorCommand=kwin_wayland' /usr/lib/sddm/sddm.conf.d/plasma-wayland.conf
rpm -qf /usr/bin/kwin_wayland
# Le service d'affichage passe de Plasma Login à SDDM. Le lien de la base,
# s'il existe, doit être celui de Plasma Login.
lien=/etc/systemd/system/display-manager.service
if [[ -L "${lien}" ]]; then
    if [[ "$(basename "$(readlink "${lien}")")" != plasmalogin.service ]]; then
        echo "${lien} désigne $(readlink "${lien}") : gestionnaire de connexion à revoir" >&2
        exit 1
    fi
    rm "${lien}"
fi
systemctl enable sddm.service
if [[ "$(basename "$(readlink "${lien}")")" != sddm.service ]]; then
    echo "${lien} ne désigne pas sddm.service : $(readlink "${lien}")" >&2
    exit 1
fi
# Réglages de SDDM pour Ankh, dans le dossier des réglages fournis par le
# système : /etc/sddm.conf.d (connexion automatique de l'assistant, ou mes
# propres réglages) passe après. Image de compte par défaut : celle d'Ankh,
# que SDDM cherche dans le dossier faces du thème (UserModel.cpp de
# https://github.com/sddm/sddm, version 0.21.0).
if grep -rqs '^Current=' /usr/lib/sddm/sddm.conf.d /etc/sddm.conf.d /etc/sddm.conf; then
    echo "Un thème SDDM est déjà choisi par la base : $(grep -rs '^Current=' /usr/lib/sddm/sddm.conf.d /etc/sddm.conf.d /etc/sddm.conf)" >&2
    exit 1
fi
install -d -m 0755 /usr/lib/sddm/sddm.conf.d /usr/share/sddm/themes/ankh/faces
cat > /usr/lib/sddm/sddm.conf.d/ankh.conf << 'CONF'
# Écran de connexion d'Ankh (D-043)
[Theme]
Current=ankh
CursorTheme=Ankh-curseurs
Font=Inter,10,-1,5,50,0,0,0,0,0
CONF
chmod 0644 /usr/lib/sddm/sddm.conf.d/ankh.conf
install -m 0644 /usr/share/ankh/avatar.png /usr/share/sddm/themes/ankh/faces/.face.icon

# Écran de démarrage graphique : Plymouth ne l'affiche (logo d'Ankh, et saisie
# du mot de passe LUKS) que si le noyau reçoit « rhgb » ; « quiet » masque les
# messages du noyau. L'installateur de Fedora (Anaconda) les ajoute ; avec
# « bootc install », les arguments du noyau viennent de /usr/lib/bootc/kargs.d,
# et un changement de ces fichiers s'applique aussi aux machines déjà
# installées, à la mise à jour suivante (docs/src/building/bootc-kernel-arguments.7.md
# de https://github.com/bootc-dev/bootc). Les captures de la VM montraient
# les messages du démarrage au lieu de l'écran d'Ankh. Ajoutés seulement si
# l'image de base ne les donne pas déjà.
if grep -qs '"rhgb"' /usr/lib/bootc/kargs.d/*.toml; then
    echo "« rhgb » déjà donné par l'image de base : $(grep -ls '"rhgb"' /usr/lib/bootc/kargs.d/*.toml)"
else
    install -d -m 0755 /usr/lib/bootc/kargs.d
    cat > /usr/lib/bootc/kargs.d/10-ankh-ecran-de-demarrage.toml << 'TOML'
# Écran de démarrage graphique d'Ankh (D-034), sans les messages du noyau.
kargs = ["rhgb", "quiet"]
TOML
fi

# D-043 : écran de démarrage entièrement d'Ankh (mon choix du 2026-10-10),
# où se tape aussi le mot de passe LUKS. Thème Plymouth « ankh »
# (build_files/files/usr/share/plymouth/themes/ankh) : le même dessin que
# l'écran de chargement de la session, sans le logo du fabricant du PC. Le
# champ du mot de passe, sa puce et le cadenas sont ceux d'Ankh ; les
# indicateurs de clavier (Verr. Maj, disposition) sont repris du thème
# « spinner » de Plymouth, celui que Fedora utilise. Remplace le seul
# changement de filigrane de D-034.
# Ce changement touche au démarrage et à la saisie du mot de passe LUKS : à relire.
theme_ankh=/usr/share/plymouth/themes/ankh
for image in capslock.png keyboard.png keymap-render.png; do
    if [[ ! -f "/usr/share/plymouth/themes/spinner/${image}" ]]; then
        echo "Thème Plymouth « spinner » : ${image} absent : écran de démarrage à revoir" >&2
        exit 1
    fi
    install -m 0644 "/usr/share/plymouth/themes/spinner/${image}" "${theme_ankh}/${image}"
done
for image in watermark.png entry.png bullet.png lock.png; do
    [[ -s "${theme_ankh}/${image}" ]] || { echo "Thème Plymouth d'Ankh : ${image} absent" >&2; exit 1; }
done
echo "Thème Plymouth de la base : $(plymouth-set-default-theme)"
plymouth-set-default-theme ankh
if [[ "$(plymouth-set-default-theme)" != ankh ]]; then
    echo "Le thème Plymouth d'Ankh n'est pas choisi : $(plymouth-set-default-theme)" >&2
    exit 1
fi

# L'écran de démarrage vit dans l'initramfs : il est reconstruit avec la
# commande qu'Universal Blue utilise pour cette même base (build_files/initramfs.sh
# de https://github.com/ublue-os/main). Une image bootc n'a qu'un noyau.
if [[ "$(find /usr/lib/modules -mindepth 1 -maxdepth 1 | wc -l)" != 1 ]]; then
    echo "Il faut exactement un noyau dans /usr/lib/modules" >&2
    exit 1
fi
kver="$(basename /usr/lib/modules/*)"
DRACUT_NO_XATTR=1 dracut --no-hostonly --kver "${kver}" --reproducible --add ostree -f "/usr/lib/modules/${kver}/initramfs.img"
chmod 0600 "/usr/lib/modules/${kver}/initramfs.img"
