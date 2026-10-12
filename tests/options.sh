#!/usr/bin/bash
# D-046 : options d'Ankh (Simple toujours incluse ; Dev ; Gaming et Hacking
# bientôt ; Complète). Lancé dans l'image par « just test » (Test 15), en root,
# dans un conteneur jetable : ce qu'il écrit dans /etc et /usr/local disparaît
# avec lui.
set -euo pipefail

echec() {
    echo "ÉCHEC : $*" >&2
    exit 1
}

menu=/usr/local/share/applications
lien() { [[ -L "${menu}/$1" && "$(readlink "${menu}/$1")" == "/usr/share/ankh/options/dev/applications/$1" ]]; }

echo "Fichiers et services des options"
test -x /usr/libexec/ankh-options || echec "/usr/libexec/ankh-options absent"
test -x /usr/libexec/ankh-options-reglages || echec "/usr/libexec/ankh-options-reglages absent"
for f in /usr/lib/systemd/system/ankh-options.service "/usr/lib/systemd/system/ankh-options@.service" \
    /usr/share/polkit-1/rules.d/50-ankh-options.rules \
    /usr/share/plasma/packages/org.ankh.plasmasetup.options/metadata.json \
    /usr/share/plasma/packages/org.ankh.plasmasetup.options/contents/ui/main.qml; do
    test -f "${f}" || echec "${f} absent"
done
test -L /etc/systemd/system/multi-user.target.wants/ankh-options.service || echec "ankh-options.service n'est pas activé"
python3 -c 'import json, sys; json.load(open(sys.argv[1]))' /usr/share/plasma/packages/org.ankh.plasmasetup.options/metadata.json
# La page des réglages est dans la Configuration du système et dans le menu
[[ "$(readlink -f /usr/share/plasma/systemsettings/externalmodules/ankh-options.desktop)" == /usr/share/applications/ankh-options.desktop ]] \
    || echec "« Options d'Ankh » absent de la Configuration du système"
desktop-file-validate /usr/share/applications/ankh-options.desktop /usr/share/ankh/options/dev/applications/*.desktop
command -v kdialog > /dev/null || echec "kdialog absent : la page « Options d'Ankh » ne s'ouvrirait pas"
# Les entrées de Dev ne sont plus dans le menu par défaut, seulement dans l'option
for f in ankh-vscode.desktop ankh-dev-mettre-a-jour.desktop; do
    test ! -e "/usr/share/applications/${f}" || echec "${f} est encore dans le menu, hors option"
    test -f "/usr/share/ankh/options/dev/applications/${f}" || echec "${f} absent de l'option Dev"
done

echo "Sans choix enregistré : comme Complète"
test ! -e /etc/ankh/options || echec "/etc/ankh/options existe déjà dans l'image"
[[ "$(/usr/libexec/ankh-options choix)" == "dev gaming hacking" ]] || echec "choix par défaut inattendu"
/usr/libexec/ankh-options synchroniser
lien ankh-vscode.desktop || echec "VS Code absent du menu avec Complète"
lien ankh-dev-mettre-a-jour.desktop || echec "« Mettre à jour les outils de dev » absent avec Complète"

echo "Simple seule : plus de VS Code"
/usr/libexec/ankh-options appliquer simple
[[ -z "$(/usr/libexec/ankh-options choix)" ]] || echec "Simple : options encore enregistrées"
test ! -e "${menu}/ankh-vscode.desktop" || echec "VS Code encore dans le menu avec Simple seule"

echo "Dev : VS Code revient ; l'ordre et les doublons ne comptent pas"
/usr/libexec/ankh-options appliquer hacking_dev_dev
[[ "$(/usr/libexec/ankh-options choix)" == "dev hacking" ]] || echec "choix enregistré inattendu : $(/usr/libexec/ankh-options choix)"
lien ankh-vscode.desktop || echec "VS Code absent du menu avec Dev"

echo "Choix refusés"
for mauvais in "dev;id" "Dev" "inconnue" "dev__gaming" "_dev" "dev gaming" ""; do
    if /usr/libexec/ankh-options appliquer "${mauvais}" 2> /dev/null; then
        echec "choix accepté à tort : « ${mauvais} »"
    fi
done
[[ "$(/usr/libexec/ankh-options choix)" == "dev hacking" ]] || echec "un choix refusé a changé l'enregistrement"

echo "La règle polkit ne vise que le compte de l'assistant et ce service"
grep -q 'subject.user !== "plasma-setup"' /usr/share/polkit-1/rules.d/50-ankh-options.rules || echec "règle polkit : compte"
grep -q '"org.freedesktop.systemd1.manage-units"' /usr/share/polkit-1/rules.d/50-ankh-options.rules || echec "règle polkit : action"
# Le compte est créé au démarrage par systemd-sysusers (files/plasma-setup-sysuser.conf de plasma-setup)
grep -qs '^u plasma-setup ' /usr/lib/sysusers.d/*.conf || echec "compte plasma-setup inconnu : la règle ne servirait à rien"

echo "Options d'Ankh : tout est en place."
