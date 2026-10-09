#!/usr/bin/bash
# Construction de l'image du conteneur de dev (D-032).
set -euo pipefail

# D-035 : Node.js dans la version la plus récente que Fedora propose, et non
# dans celle que Fedora choisit par défaut. Fedora fournit chaque version
# majeure dans ses propres paquets (nodejs22, nodejs24…) ; leurs sous-paquets
# -bin et -npm-bin donnent les commandes node, npm et npx sans numéro
# (nodejsNN.spec, paquets de Fedora repris par CentOS Stream, par exemple
# https://gitlab.com/redhat/centos-stream/rpms/nodejs26). Node.js s'installe
# avant la liste, pour qu'aucun paquet n'y tire la version par défaut.
if ! node_majeure="$(dnf5 repoquery --qf '%{name}\n' 'nodejs*' | grep -xE 'nodejs[0-9]+' | sed 's/^nodejs//' | sort -n | tail -n 1)" ||
    [[ -z "${node_majeure}" ]]; then
    echo "Aucun paquet nodejsNN dans les dépôts de Fedora" >&2
    exit 1
fi
echo "Node.js ${node_majeure} : la version la plus récente proposée par Fedora"
node="nodejs${node_majeure}"
dnf5 -y install "${node}" "${node}-npm" "${node}-bin" "${node}-npm-bin"

# Paquets Fedora de la liste.
mapfile -t packages < <(grep -Ev '^[[:space:]]*(#|$)' /ctx/packages.txt)
dnf5 -y install "${packages[@]}"

# D-035 : la dernière version d'OpenJDK (java-latest-openjdk) devient celle
# des commandes java et javac. Sinon, Fedora garde sa version de référence,
# que Maven installe pour lui-même (vu en CI : la 25, D-032). Maven reste sur
# cette version de référence.
for commande in java javac; do
    mapfile -t chemins < <(rpm -qal 'java-latest-openjdk*' | grep -E "/bin/${commande}\$")
    if [[ ${#chemins[@]} -ne 1 ]]; then
        echo "java-latest-openjdk : une commande ${commande} attendue, trouvées : ${chemins[*]:-aucune}" >&2
        exit 1
    fi
    alternatives --set "${commande}" "${chemins[0]}"
    echo "${commande} : ${chemins[0]}"
done

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
