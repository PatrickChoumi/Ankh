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

# Écran de démarrage, où se tape aussi le mot de passe LUKS : le logo d'Ankh
# remplace celui de Fedora en bas de l'écran. Le thème de Plymouth reste celui
# de Fedora ; seule son image de filigrane change.
theme="$(plymouth-set-default-theme)"
images="$(sed -n 's/^ImageDir=//p' "/usr/share/plymouth/themes/${theme}/${theme}.plymouth")"
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
