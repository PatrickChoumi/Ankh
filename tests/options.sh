#!/usr/bin/bash
# D-046 : options d'Ankh (Simple toujours incluse ; Dev ; Gaming ; Création ;
# Hacking bientôt ; Complète), page de l'assistant et fenêtre « Options d'Ankh ».
# Le contenu des options Gaming et Création a son propre test (tests/gaming.sh,
# tests/craft.sh).
# Lancé dans l'image par « just test » (Test 15), en root,
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
plasmoide=/usr/share/plasma/plasmoids/org.ankh.options
composants=/usr/lib64/qt6/qml/org/ankh/composants
for f in /usr/lib/systemd/system/ankh-options.service "/usr/lib/systemd/system/ankh-options@.service" \
    /usr/share/polkit-1/rules.d/50-ankh-options.rules \
    /usr/share/polkit-1/actions/org.ankh.options.policy \
    /usr/share/plasma/packages/org.ankh.plasmasetup.options/metadata.json \
    /usr/share/plasma/packages/org.ankh.plasmasetup.options/contents/ui/main.qml \
    "${plasmoide}/metadata.json" "${plasmoide}/contents/ui/main.qml" "${plasmoide}/contents/ui/Fenetre.qml" \
    "${composants}/qmldir" "${composants}/CarteOption.qml" "${composants}/ListeOptions.qml"; do
    test -f "${f}" || echec "${f} absent"
done
test -L /etc/systemd/system/multi-user.target.wants/ankh-options.service || echec "ankh-options.service n'est pas activé"
python3 -c 'import json, sys; json.load(open(sys.argv[1]))' /usr/share/plasma/packages/org.ankh.plasmasetup.options/metadata.json

echo "La fenêtre « Options d'Ankh » et ses cartes"
# Widget de Plasma ouvert par plasmawindowed, caché de la liste des widgets
python3 - "${plasmoide}/metadata.json" << 'PY' || echec "métadonnées du widget org.ankh.options"
import json, sys
m = json.load(open(sys.argv[1]))
assert m["KPackageStructure"] == "Plasma/Applet", m["KPackageStructure"]
assert m["KPlugin"]["Id"] == "org.ankh.options", m["KPlugin"]["Id"]
assert m["KPlugin"]["Name"] == "Options d'Ankh", m["KPlugin"]["Name"]
assert m["NoDisplay"] is True
PY
# Les cartes sont partagées par l'assistant et la fenêtre
grep -qx 'module org.ankh.composants' "${composants}/qmldir" || echec "module QML org.ankh.composants mal déclaré"
for f in /usr/share/plasma/packages/org.ankh.plasmasetup.options/contents/ui/main.qml "${plasmoide}/contents/ui/Fenetre.qml"; do
    grep -q '^import org.ankh.composants as Ankh$' "${f}" || echec "${f} n'utilise pas les cartes partagées"
    grep -q 'Ankh.ListeOptions {' "${f}" || echec "${f} n'affiche pas les cartes partagées"
done
# La page des réglages est dans la Configuration du système et dans le menu
[[ "$(readlink -f /usr/share/plasma/systemsettings/externalmodules/ankh-options.desktop)" == /usr/share/applications/ankh-options.desktop ]] \
    || echec "« Options d'Ankh » absent de la Configuration du système"
desktop-file-validate /usr/share/applications/ankh-options.desktop /usr/share/ankh/options/dev/applications/*.desktop
grep -qx 'Exec=plasmawindowed org.ankh.options' /usr/share/applications/ankh-options.desktop || echec "« Options d'Ankh » n'ouvre pas sa fenêtre"
grep -qx 'StartupWMClass=org.kde.plasmawindowed' /usr/share/applications/ankh-options.desktop || echec "la barre ne relierait pas la fenêtre à « Options d'Ankh »"
for outil in plasmawindowed pkexec kbuildsycoca6 busctl; do
    command -v "${outil}" > /dev/null || echec "${outil} absent : la fenêtre « Options d'Ankh » ne fonctionnerait pas"
done
# L'agent polkit de KDE montre la fenêtre du mot de passe
test -x /usr/libexec/kf6/polkit-kde-authentication-agent-1 || echec "agent polkit de KDE absent : pas de fenêtre de mot de passe"
# Sans choix valide, rien n'est demandé ni appliqué
for mauvais in "" "dev;id" "Dev"; do
    if /usr/libexec/ankh-options-reglages appliquer "${mauvais}" 2> /dev/null; then
        echec "ankh-options-reglages accepte à tort « ${mauvais} »"
    fi
done
# Les entrées de Dev ne sont plus dans le menu par défaut, seulement dans l'option
for f in ankh-vscode.desktop ankh-dev-mettre-a-jour.desktop; do
    test ! -e "/usr/share/applications/${f}" || echec "${f} est encore dans le menu, hors option"
    test -f "/usr/share/ankh/options/dev/applications/${f}" || echec "${f} absent de l'option Dev"
done

echo "Sans choix enregistré : comme Complète"
test ! -e /etc/ankh/options || echec "/etc/ankh/options existe déjà dans l'image"
[[ "$(/usr/libexec/ankh-options choix)" == "dev gaming creation hacking" ]] || echec "choix par défaut inattendu"
/usr/libexec/ankh-options synchroniser
lien ankh-vscode.desktop || echec "VS Code absent du menu avec Complète"
lien ankh-dev-mettre-a-jour.desktop || echec "« Mettre à jour les outils de dev » absent avec Complète"
test -L "${menu}/com.valvesoftware.Steam.desktop" || echec "Steam absent du menu avec Complète"
test -L /usr/local/share/wayland-sessions/ankh-console.desktop || echec "session « Ankh Console » absente avec Complète"
test -L "${menu}/ai.storyteller.photocraft.desktop" || echec "PhotoCraft absent du menu avec Complète"

echo "Simple seule : plus de VS Code"
/usr/libexec/ankh-options appliquer simple
[[ -z "$(/usr/libexec/ankh-options choix)" ]] || echec "Simple : options encore enregistrées"
test ! -e "${menu}/ankh-vscode.desktop" || echec "VS Code encore dans le menu avec Simple seule"
test ! -e "${menu}/com.valvesoftware.Steam.desktop" || echec "Steam encore dans le menu avec Simple seule"
test ! -e /usr/local/share/wayland-sessions/ankh-console.desktop || echec "session « Ankh Console » encore là avec Simple seule"
test ! -e "${menu}/ai.storyteller.photocraft.desktop" || echec "PhotoCraft encore dans le menu avec Simple seule"
test -f /usr/share/applications/ai.storyteller.wordcraft.desktop || echec "WordCraft absent du menu avec Simple seule"

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

echo "Option d'une version plus récente (avant un retour arrière) : ignorée, gardée"
printf 'OPTIONS=dev future\n' > /etc/ankh/options
/usr/libexec/ankh-options synchroniser 2> /tmp/synchroniser.txt || echec "une option inconnue bloque les options connues"
grep -q "ignorée : future" /tmp/synchroniser.txt || echec "l'option inconnue n'est pas signalée"
lien ankh-vscode.desktop || echec "VS Code absent du menu à côté d'une option inconnue"
grep -qx 'OPTIONS=dev future' /etc/ankh/options || echec "l'option inconnue n'est plus enregistrée"
/usr/libexec/ankh-options appliquer dev_hacking

echo "La règle polkit ne vise que le compte de l'assistant et ce service"
grep -q 'subject.user !== "plasma-setup"' /usr/share/polkit-1/rules.d/50-ankh-options.rules || echec "règle polkit : compte"
grep -q '"org.freedesktop.systemd1.manage-units"' /usr/share/polkit-1/rules.d/50-ankh-options.rules || echec "règle polkit : action"
# Le compte est créé au démarrage par systemd-sysusers (files/plasma-setup-sysuser.conf de plasma-setup)
grep -qs '^u plasma-setup ' /usr/lib/sysusers.d/*.conf || echec "compte plasma-setup inconnu : la règle ne servirait à rien"

echo "L'action polkit de la fenêtre demande toujours le mot de passe d'un administrateur"
python3 - /usr/share/polkit-1/actions/org.ankh.options.policy << 'PY' || echec "action polkit org.ankh.options.appliquer"
import sys
import xml.etree.ElementTree as ET
actions = ET.parse(sys.argv[1]).getroot().findall("action")
assert [a.get("id") for a in actions] == ["org.ankh.options.appliquer"], [a.get("id") for a in actions]
action = actions[0]
annotations = {a.get("key"): a.text for a in action.findall("annotate")}
assert annotations == {"org.freedesktop.policykit.exec.path": "/usr/libexec/ankh-options"}, annotations
defauts = {d.tag: d.text for d in action.find("defaults")}
assert defauts == {"allow_any": "auth_admin", "allow_inactive": "auth_admin", "allow_active": "auth_admin_keep"}, defauts
PY

echo "Options d'Ankh : tout est en place."
