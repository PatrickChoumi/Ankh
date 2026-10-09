#!/usr/bin/bash
# Construction de l'image du conteneur de dev (D-032).
set -euo pipefail

# Paquets Fedora de la liste.
mapfile -t packages < <(grep -Ev '^[[:space:]]*(#|$)' /ctx/packages.txt)
dnf5 -y install "${packages[@]}"

# VS Code officiel de Microsoft, depuis son dépôt RPM :
# https://code.visualstudio.com/docs/setup/linux
# La clé est refusée si son empreinte n'est pas celle publiée par Microsoft
# (https://learn.microsoft.com/linux/packages). gpg travaille dans un dossier
# temporaire.
ms_fpr=BC528686B50D79E339D3721CEB3E94ADBE1229CF
ms_key=/etc/pki/rpm-gpg/microsoft.asc
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc -o "${ms_key}"
gnupg_home=$(mktemp -d)
fpr=$(gpg --homedir "${gnupg_home}" --show-keys --with-colons "${ms_key}" | awk -F: '/^fpr:/ {print $10; exit}')
rm -rf "${gnupg_home}"
if [[ "${fpr}" != "${ms_fpr}" ]]; then
    echo "Clé de Microsoft inattendue : ${fpr} (attendu ${ms_fpr})" >&2
    exit 1
fi
rpm --import "${ms_key}"
cat > /etc/yum.repos.d/vscode.repo << REPO
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=file://${ms_key}
REPO
dnf5 -y install code

# podman et podman-compose du conteneur pilotent le Podman du système, par le
# socket de l'utilisateur (activé dans l'image Ankh) : les serveurs de bases
# de données tournent dans des conteneurs du système.
ln -s /usr/bin/podman-remote /usr/local/bin/podman
install -m 0644 /ctx/profile.sh /etc/profile.d/ankh-dev.sh

# Réglage de VS Code et extensions, appliqués à la création du conteneur.
install -m 0755 /ctx/setup.sh /usr/libexec/ankh-dev-setup
install -D -m 0644 /ctx/vscode-extensions.txt /usr/share/ankh-dev/vscode-extensions.txt
