#!/usr/bin/bash
# Lancé dans le conteneur de dev, avec mon compte, juste après sa création
# (D-032) : installe les extensions VS Code de la liste et règle VS Code pour
# qu'il ne se mette pas à jour tout seul (D-031), avec la police et les
# couleurs d'Ankh (D-042). Un réglage existant n'est jamais écrasé.
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
    # Couleurs : le thème sombre de VS Code, avec le violet d'Ankh à la place
    # du bleu (Ankh.colors : #8455f0 pour les sélections et les boutons,
    # #a78bfa pour le focus et les liens). Clés de
    # https://code.visualstudio.com/api/references/theme-color, limitées à ce
    # thème (« [Default Dark Modern] », https://code.visualstudio.com/docs/configure/themes).
    cat > "${settings}" << 'JSON'
{
    "extensions.autoUpdate": false,
    "update.mode": "none",
    "editor.fontFamily": "'JetBrains Mono', monospace",
    "editor.fontLigatures": true,
    "editor.fontSize": 14,
    "terminal.integrated.fontFamily": "'JetBrains Mono', monospace",
    "workbench.colorTheme": "Default Dark Modern",
    "workbench.colorCustomizations": {
        "[Default Dark Modern]": {
            "focusBorder": "#a78bfa",
            "button.background": "#8455f0",
            "button.hoverBackground": "#7c3aed",
            "badge.background": "#8455f0",
            "activityBarBadge.background": "#8455f0",
            "activityBar.activeBorder": "#a78bfa",
            "statusBarItem.remoteBackground": "#8455f0",
            "progressBar.background": "#a78bfa",
            "textLink.foreground": "#a78bfa",
            "textLink.activeForeground": "#c4b5fd",
            "editorCursor.foreground": "#a78bfa",
            "tab.activeBorderTop": "#a78bfa",
            "panelTitle.activeBorder": "#a78bfa",
            "inputOption.activeBorder": "#a78bfa",
            "list.activeSelectionBackground": "#8455f040",
            "editor.selectionBackground": "#8455f055"
        }
    }
}
JSON
fi
