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
# comme Chrome (modifie D-011 et D-024) : VLC et OnlyOffice. Elles se mettent
# à jour avec l'image, chaque semaine (D-023, D-031).
#
# LibreOffice est retiré : une seule suite bureautique, OnlyOffice. Tous ses
# paquets, s'il y en a dans la base. La liste de ce qui part est affichée.
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

# OnlyOffice, depuis son dépôt officiel pour Red Hat et dérivés
# (https://helpcenter.onlyoffice.com/desktop/installation/desktop-install-rhel.aspx),
# installé dans /opt comme Chrome. La clé de signature est refusée si son
# empreinte n'est pas celle-ci : la documentation d'OnlyOffice pour Ubuntu
# désigne la clé par son identifiant court CB2DE8E5, sur keyserver.ubuntu.com
# (https://helpcenter.onlyoffice.com/installation/desktop-install-ubuntu.aspx),
# et ce serveur donne cette empreinte complète, au nom d'Ascensio System
# (l'éditeur d'OnlyOffice). La clé est prise sur ce même serveur.
onlyoffice_fpr=E09CA29F6E178040EF22B4098320CA65CB2DE8E5
onlyoffice_key=/etc/pki/rpm-gpg/onlyoffice.asc
curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${onlyoffice_fpr}" -o "${onlyoffice_key}"
gnupg_home=$(mktemp -d)
fpr=$(gpg --homedir "${gnupg_home}" --show-keys --with-colons "${onlyoffice_key}" | awk -F: '/^fpr:/ {print $10; exit}')
rm -rf "${gnupg_home}"
if [[ "${fpr}" != "${onlyoffice_fpr}" ]]; then
    echo "Clé d'OnlyOffice inattendue : ${fpr} (attendu ${onlyoffice_fpr})" >&2
    exit 1
fi
rpm --import "${onlyoffice_key}"
cat > /etc/yum.repos.d/onlyoffice.repo << REPO
[onlyoffice]
name=onlyoffice
baseurl=https://download.onlyoffice.com/repo/centos/main/noarch/
enabled=1
gpgcheck=1
gpgkey=file://${onlyoffice_key}
REPO
dnf5 -y install onlyoffice-desktopeditors

# Applications par défaut (spécification XDG, comme Chrome plus haut) : VLC
# pour la vidéo et l'audio, OnlyOffice pour les documents de bureau. Les
# formats sont ceux que chaque application déclare dans son lanceur, filtrés :
# OnlyOffice déclare aussi le PDF et le texte brut, qui restent à Chrome et à
# l'éditeur de texte.
# Le lanceur principal porte le nom de l'application et appartient à l'un de
# ses paquets (VLC en a d'autres, pour ouvrir un DVD, un Blu-ray…).
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
vlc_lanceur="$(lanceur vlc)"
onlyoffice_lanceur="$(lanceur onlyoffice-desktopeditors)"
mapfile -t vlc_formats < <(formats "${vlc_lanceur}" '^(video|audio)/')
mapfile -t onlyoffice_formats < <(formats "${onlyoffice_lanceur}" \
    '^(application/(msword|rtf|vnd\.ms-(excel|powerpoint|word)|vnd\.openxmlformats-officedocument\.|vnd\.oasis\.opendocument\.(text|spreadsheet|presentation))|text/(csv|rtf)$)')
if [[ ${#vlc_formats[@]} -eq 0 || ${#onlyoffice_formats[@]} -eq 0 ]]; then
    echo "Formats introuvables : ${#vlc_formats[@]} pour VLC, ${#onlyoffice_formats[@]} pour OnlyOffice" >&2
    exit 1
fi
echo "VLC (${vlc_lanceur}) par défaut pour ${#vlc_formats[@]} formats"
echo "OnlyOffice (${onlyoffice_lanceur}) par défaut pour ${#onlyoffice_formats[@]} formats"
for t in "${vlc_formats[@]}"; do
    echo "${t}=$(basename "${vlc_lanceur}")"
done >> /etc/xdg/mimeapps.list
for t in "${onlyoffice_formats[@]}"; do
    echo "${t}=$(basename "${onlyoffice_lanceur}")"
done >> /etc/xdg/mimeapps.list

# Claude et GitHub (D-024) : applications web que Chrome installe lui-même,
# dans leur propre fenêtre, par sa politique WebAppInstallForceList
# (fichier /etc/opt/chrome/policies/managed/ankh-applications.json, copié
# avec les autres fichiers d'Ankh plus bas). Définition de la politique :
# components/policy/resources/templates/policy_definitions/Miscellaneous/WebAppInstallForceList.yaml
# dans https://github.com/chromium/chromium.

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
# Polices de Fedora : Inter pour l'interface, JetBrains Mono pour le terminal
# et le code.
dnf5 -y install rsms-inter-fonts jetbrains-mono-fonts

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
# Polices, au format des réglages de Fedora (kde-profile/default/xdg/kdeglobals).
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key font 'Inter,10,-1,5,50,0,0,0,0,0'
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key menuFont 'Inter,10,-1,5,50,0,0,0,0,0'
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key toolBarFont 'Inter,10,-1,5,50,0,0,0,0,0'
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key smallestReadableFont 'Inter,8,-1,5,50,0,0,0,0,0'
kwriteconfig6 --file /etc/xdg/kdeglobals --group General --key fixed 'JetBrains Mono,10,-1,5,50,0,0,0,0,0'
kwriteconfig6 --file /etc/xdg/kdeglobals --group WM --key activeFont 'Inter,10,-1,5,63,0,0,0,0,0'

# Barre flottante en bas, menu et applications au centre (build_files/plasma/ankh-barre.js),
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
chmod 0644 /etc/xdg/kdeglobals /etc/xdg/breezerc /etc/xdg/konsolerc "${sombre}/contents/defaults"

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
    org.kde.discover.desktop "$(basename "${vlc_lanceur}")" "$(basename "${onlyoffice_lanceur}")" systemsettings.desktop)
for favori in "${favoris[@]}"; do
    if [[ "${favori}" == *.desktop && ! -e "/usr/share/applications/${favori}" ]]; then
        echo "Favori du menu introuvable : /usr/share/applications/${favori}" >&2
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

# Écran de démarrage, où se tape aussi le mot de passe LUKS : le logo d'Ankh
# remplace celui de Fedora en bas de l'écran. Le thème de Plymouth reste celui
# de Fedora ; seule son image de filigrane change.
theme="$(plymouth-set-default-theme)"
images="$(sed -n 's/^ImageDir=//p' "/usr/share/plymouth/themes/${theme}/${theme}.plymouth")"
# Fedora écrit ce chemin avec « // » : il est normalisé.
images="$(realpath -m "${images}")"
if [[ -z "${images}" || ! -d "${images}" ]]; then
    echo "Thème Plymouth « ${theme} » : dossier d'images introuvable (« ${images} »)" >&2
    exit 1
fi
echo "Thème Plymouth « ${theme} », images dans ${images}"
install -m 0644 /usr/share/ankh/plymouth/watermark.png "${images}/watermark.png"

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
