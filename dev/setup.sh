#!/usr/bin/bash
# Lancé dans le conteneur de dev, avec mon compte, juste après sa création
# (D-032) : installe les extensions VS Code de la liste et règle VS Code pour
# qu'il ne se mette pas à jour tout seul (D-031). Un réglage existant n'est
# jamais écrasé.
set -euo pipefail

while read -r extension; do
    if [[ -z "${extension}" || "${extension}" == \#* ]]; then
        continue
    fi
    code --install-extension "${extension}"
done < /usr/share/ankh-dev/vscode-extensions.txt

settings="${HOME}/.config/Code/User/settings.json"
if [[ ! -e "${settings}" ]]; then
    mkdir -p "$(dirname "${settings}")"
    cat > "${settings}" << 'JSON'
{
    "extensions.autoUpdate": false,
    "update.mode": "none"
}
JSON
fi
