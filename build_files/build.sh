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
fpr=$(gpg --show-keys --with-colons "${google_key}" | awk -F: '/^fpr:/ {print $10; exit}')
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
