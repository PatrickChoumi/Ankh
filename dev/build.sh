#!/usr/bin/bash
# Construction de l'image du conteneur de dev (D-032).
set -euo pipefail

# D-038 : Node.js et Java dans leur dernière version LTS (support long)
# proposée par Fedora, et non dans la plus récente (modifie D-035).
#
# Node.js : Fedora fournit chaque version majeure dans ses propres paquets
# (nodejs22, nodejs24…) ; leurs sous-paquets -bin et -npm-bin donnent les
# commandes node, npm et npx sans numéro (nodejsNN.spec, paquets de Fedora
# repris par CentOS Stream, par exemple
# https://gitlab.com/redhat/centos-stream/rpms/nodejs26). Le calendrier
# officiel de Node.js donne la date d'entrée en LTS et la fin de vie de chaque
# version (schedule.json de https://github.com/nodejs/Release) : on garde les
# versions proposées par Fedora déjà en LTS et pas en fin de vie, et on prend
# la plus récente. Node.js s'installe avant la liste, pour qu'aucun paquet n'y
# tire la version par défaut de Fedora.
dnf5 -y install python3
mapfile -t node_fedora < <(dnf5 repoquery --qf '%{name}\n' 'nodejs*' | grep -xE 'nodejs[0-9]+' | sed 's/^nodejs//' | sort -un)
curl -fsSL https://raw.githubusercontent.com/nodejs/Release/main/schedule.json -o /tmp/node-schedule.json
node_majeure="$(python3 /ctx/lts.py node /tmp/node-schedule.json "${node_fedora[@]}")"
echo "Node.js ${node_majeure} : la dernière LTS proposée par Fedora (proposées : ${node_fedora[*]})"
node="nodejs${node_majeure}"
dnf5 -y install "${node}" "${node}-npm" "${node}-bin" "${node}-npm-bin"

# Java : depuis Java 17, une version LTS sort tous les deux ans, soit une
# version sur quatre : 17, 21, 25, 29… (Java SE Support Roadmap d'Oracle,
# https://www.oracle.com/java/technologies/java-se-support-roadmap.html).
# On prend la plus récente des versions LTS que Fedora propose
# (java-NN-openjdk), et elle devient celle des commandes java et javac.
mapfile -t java_fedora < <(dnf5 repoquery --qf '%{name}\n' 'java-*-openjdk-devel' | sed -nE 's/^java-([0-9]+)-openjdk-devel$/\1/p' | sort -un)
java_majeure="$(python3 /ctx/lts.py java "${java_fedora[@]}")"
echo "Java ${java_majeure} : la dernière LTS proposée par Fedora (proposées : ${java_fedora[*]})"
dnf5 -y install "java-${java_majeure}-openjdk-devel"

# Paquets Fedora de la liste.
mapfile -t packages < <(grep -Ev '^[[:space:]]*(#|$)' /ctx/packages.txt)
dnf5 -y install "${packages[@]}"

# D-038 : java et javac pointent vers la version LTS choisie plus haut, même
# si un paquet de la liste en installe une autre (Maven tire sa version de
# référence).
for commande in java javac; do
    mapfile -t chemins < <(rpm -qal "java-${java_majeure}-openjdk*" | grep -E "^/usr/lib/jvm/.*/bin/${commande}\$")
    if [[ ${#chemins[@]} -ne 1 ]]; then
        echo "java-${java_majeure}-openjdk : une commande ${commande} attendue, trouvées : ${chemins[*]:-aucune}" >&2
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
