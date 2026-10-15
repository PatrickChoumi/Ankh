#!/usr/bin/bash
# D-053 : la suite Craft d'ArtCraft, à la place d'OnlyOffice. WordCraft,
# GridCraft et DeckCraft dans le menu de toute installation (Simple), les sept
# autres avec l'option Création ; versions et empreintes figées dans l'image,
# préparées au premier clic par ankh-craft et son service.
# Lancé dans l'image par « just test » (Test 17), en root, dans un conteneur
# jetable et sans réseau : rien n'est téléchargé, et ce qu'il écrit dans /etc
# et /usr/local disparaît avec lui.
set -euo pipefail

echec() {
    echo "ÉCHEC : $*" >&2
    exit 1
}

versions=/usr/share/ankh/craft/versions
creation=/usr/share/ankh/options/creation/applications
simple=(wordcraft gridcraft deckcraft)
options_creation=(photocraft vectorcraft filmcraft lightcraft pdfcraft effectcraft designcraft)

echo "OnlyOffice absent : paquets, dépôt, clé, entrées du menu"
[[ -z "$(rpm -qa 'onlyoffice*')" ]] || echec "paquets OnlyOffice présents : $(rpm -qa 'onlyoffice*' | tr '\n' ' ')"
for f in /etc/yum.repos.d/onlyoffice.repo /etc/pki/rpm-gpg/onlyoffice.asc /opt/onlyoffice; do
    test ! -e "${f}" || echec "${f} est encore là"
done
for f in /usr/share/applications/*.desktop; do
    [[ "${f,,}" != *onlyoffice* ]] || echec "entrée d'OnlyOffice présente : ${f}"
done

echo "Lanceur, service et règle polkit"
test -x /usr/libexec/ankh-craft || echec "/usr/libexec/ankh-craft absent"
for f in "/usr/lib/systemd/system/ankh-craft@.service" /usr/share/polkit-1/rules.d/50-ankh-craft.rules \
    /etc/xdg/autostart/ankh-craft-nouveautes.desktop; do
    test -f "${f}" || echec "${f} absent"
done
grep -qx 'ExecStart=/usr/libexec/ankh-craft installer %i' "/usr/lib/systemd/system/ankh-craft@.service" ||
    echec "le service ne lance pas ankh-craft installer"
grep -qx 'RuntimeDirectory=ankh-craft/%i' "/usr/lib/systemd/system/ankh-craft@.service" ||
    echec "le service n'a pas de dossier pour son journal"
# La règle ne vise que ce service, son démarrage, et un administrateur dans
# sa session active et locale
regle=/usr/share/polkit-1/rules.d/50-ankh-craft.rules
for motif in '"org.freedesktop.systemd1.manage-units"' '!subject.active' '!subject.local' 'subject.isInGroup("wheel")' \
    '/^ankh-craft@[a-z]+\.service$/' 'action.lookup("verb") === "start"'; do
    grep -qF "${motif}" "${regle}" || echec "règle polkit : « ${motif} » absent"
done
desktop-file-validate /etc/xdg/autostart/ankh-craft-nouveautes.desktop
grep -qx 'Exec=/usr/libexec/ankh-craft nouveautes' /etc/xdg/autostart/ankh-craft-nouveautes.desktop ||
    echec "la session ne propose pas les nouvelles versions"
command -v notify-send konsole tail curl sha256sum flatpak gio > /dev/null || echec "outil de la suite Craft absent"

echo "Versions figées dans l'image"
cat "${versions}"
mapfile -t lignes < <(grep -v '^#' "${versions}")
[[ ${#lignes[@]} -eq 10 ]] || echec "10 applications attendues dans ${versions}, ${#lignes[@]} trouvées"
for ligne in "${lignes[@]}"; do
    read -r option nom version empreinte adresse reste <<< "${ligne}"
    [[ -z "${reste}" ]] || echec "${nom} : ligne inattendue : ${ligne}"
    [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || echec "${nom} : version inattendue : ${version}"
    [[ "${empreinte}" =~ ^[0-9a-f]{64}$ ]] || echec "${nom} : empreinte inattendue : ${empreinte}"
    [[ "${adresse}" == "https://github.com/storytold/${nom}/releases/download/v${version}/${nom}-${version}-linux-x86_64.flatpak" ]] ||
        echec "${nom} : adresse inattendue : ${adresse}"
    case "${option}" in
        simple)
            entree="/usr/share/applications/ai.storyteller.${nom}.desktop"
            [[ " ${simple[*]} " == *" ${nom} "* ]] || echec "${nom} n'est pas une application de Simple"
            test ! -e "${creation}/ai.storyteller.${nom}.desktop" || echec "${nom} est aussi dans l'option Création"
            ;;
        creation)
            entree="${creation}/ai.storyteller.${nom}.desktop"
            [[ " ${options_creation[*]} " == *" ${nom} "* ]] || echec "${nom} n'est pas une application de Création"
            test ! -e "/usr/share/applications/ai.storyteller.${nom}.desktop" || echec "${nom} est dans le menu sans l'option Création"
            ;;
        *) echec "${nom} : option inattendue : ${option}" ;;
    esac
    test -f "${entree}" || echec "${nom} : entrée ${entree} absente"
    desktop-file-validate "${entree}"
    grep -qx "Exec=/usr/libexec/ankh-craft ai.storyteller.${nom} %F" "${entree}" || echec "${nom} : ne passe pas par ankh-craft"
    grep -qx "Icon=ai.storyteller.${nom}" "${entree}" || echec "${nom} : icône inattendue"
    test -f "/usr/share/icons/hicolor/scalable/apps/ai.storyteller.${nom}.svg" || echec "${nom} : icône absente du thème"
    grep -aq "ai.storyteller.${nom}" /usr/share/icons/hicolor/icon-theme.cache || echec "${nom} : icône absente du cache"
    echo "${nom} ${version} (${option})"
done
for nom in "${simple[@]}" "${options_creation[@]}"; do
    grep -q "^[a-z]* ${nom} " "${versions}" || echec "${nom} absent de ${versions}"
done

echo "Rien d'installé dans l'image ; un nom inconnu est refusé"
[[ -z "$(/usr/libexec/ankh-craft installees)" ]] || echec "des applications Craft sont déjà installées dans l'image"
for mauvais in "inconnue" "word;id" "WordCraft" "../wordcraft" ""; do
    if /usr/libexec/ankh-craft installer "${mauvais}" 2> /dev/null; then
        echec "ankh-craft installer accepte à tort « ${mauvais} »"
    fi
    if /usr/libexec/ankh-craft preparer "${mauvais}" 2> /dev/null; then
        echec "ankh-craft preparer accepte à tort « ${mauvais} »"
    fi
done
if /usr/libexec/ankh-craft ai.storyteller.inconnue 2> /dev/null; then
    echec "ankh-craft ouvre à tort une application inconnue"
fi

echo "Création : sans l'option, ses applications ne s'installent pas et quittent le menu"
/usr/libexec/ankh-options appliquer dev
for nom in "${options_creation[@]}"; do
    test ! -e "/usr/local/share/applications/ai.storyteller.${nom}.desktop" || echec "${nom} reste dans le menu sans Création"
done
# Refusé avant tout téléchargement (le conteneur n'a pas de réseau)
if sortie="$(/usr/libexec/ankh-craft installer photocraft 2>&1)"; then
    echec "ankh-craft installe PhotoCraft sans l'option Création"
fi
[[ "${sortie}" == *"n'est pas choisie"* ]] || echec "refus inattendu sans l'option Création : ${sortie}"
/usr/libexec/ankh-options appliquer creation
for nom in "${options_creation[@]}"; do
    [[ "$(readlink "/usr/local/share/applications/ai.storyteller.${nom}.desktop")" == "${creation}/ai.storyteller.${nom}.desktop" ]] ||
        echec "${nom} absent du menu avec Création"
done
# Simple reste là, quelles que soient les options
/usr/libexec/ankh-options appliquer simple
for nom in "${simple[@]}"; do
    test -f "/usr/share/applications/ai.storyteller.${nom}.desktop" || echec "${nom} absent du menu avec Simple seule"
done

echo "Suite Craft : tout est en place."
