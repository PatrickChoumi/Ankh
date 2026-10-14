#!/usr/bin/bash
# Phase 2 (D-004, D-027) : prouve le modèle image-based dans une VM.
#
# Usage, en root avec KVM, QEMU et OVMF : tests/vm/run.sh [IMAGE]
#   IMAGE : image à installer, présente dans le stockage podman de root.
#           Défaut : localhost/ankh:latest (« sudo just build ankh »).
#
# Étapes, toutes vérifiées automatiquement :
#   1. installation de IMAGE sur un disque virtuel, puis démarrage complet ;
#   2. mise à jour vers la version publiée (ghcr.io/patrickchoumi/ankh:latest),
#      le registre que suit le système installé, comme sur ma machine ;
#   3. retour arrière (bootc rollback) vers IMAGE ;
#   4. retour à l'image de base épinglée dans bases.env (D-005, D-018).
# À chaque démarrage : Secure Boot actif (D-006), SELinux en mode enforcing
# et pare-feu actif (D-008). Sur IMAGE : numéro de version d'Ankh (D-028),
# Chrome qui démarre et Firefox absent (D-023).
#
# Captures d'écran de la VM à chaque étape, dans $work/captures : écran de
# connexion, bureau KDE (compte de test « ankhvm » connecté automatiquement
# par le gestionnaire de connexion),
# Discover, Chrome, VLC, OnlyOffice et VS Code (premier clic). Après chaque
# capture de Discover, son journal, pour expliquer un message d'erreur (D-028).
# À l'étape 1, l'interface d'Ankh (D-037, D-039) : réglages appliqués dans la
# session, menu, Dolphin, Konsole, réglages des couleurs, écrans de connexion
# et de verrouillage.
#
# Variables facultatives : ANKH_VM_OTHER (image de l'étape 2),
# ANKH_VM_WORKDIR (dossier de travail), ANKH_VM_SSH_PORT (port local),
# ANKH_VM_GAMING_COMPLET=1 (premier clic sur toutes les applications de
# l'option Gaming, pas seulement Steam : plusieurs Go depuis Flathub).
set -euo pipefail

image=${1:-localhost/ankh:latest}
other=${ANKH_VM_OTHER:-ghcr.io/patrickchoumi/ankh:latest}
repo=$(cd "$(dirname "$0")/../.." && pwd)
work=${ANKH_VM_WORKDIR:-$(mktemp -d)}
port=${ANKH_VM_SSH_PORT:-2222}
gaming_complet=${ANKH_VM_GAMING_COMPLET:-0}
ovmf=/usr/share/OVMF
qemu_pid=
boot_id=
autologin_main=no

# Échecs de services propres à la VM de test, avec le message qui les prouve.
# Tout autre service en échec fait échouer le test.
# - mcelog s'arrête sur les processeurs AMD récents (« CPU is unsupported »,
#   https://github.com/andikleen/mcelog/blob/master/mcelog.c). Sur un vrai
#   PC AMD, son unité est ignorée car le module edac_mce_amd est chargé
#   (https://github.com/andikleen/mcelog/blob/master/mcelog.service) ; ce
#   module ne se charge pas dans la VM, dont le processeur est celui de la
#   machine GitHub.
declare -A known_failures=(
    [mcelog.service]='CPU is unsupported'
)

log() { printf '\n==> %s\n' "$*"; }
die() {
    printf '\nÉCHEC : %s\n' "$*" >&2
    exit 1
}

cleanup() {
    local rc=$?
    if [[ -n $qemu_pid ]] && kill -0 "$qemu_pid" 2> /dev/null; then
        kill "$qemu_pid"
    fi
    if ((rc != 0)) && [[ -f $work/serial.log ]]; then
        log "Fin du journal série de la VM ($work/serial.log)"
        tail -n 200 "$work/serial.log"
    fi
}
trap cleanup EXIT

# Commande dans la VM, en root, par SSH.
vm() {
    ssh -n -i "$work/id_ed25519" -p "$port" \
        -o BatchMode=yes -o ConnectTimeout=5 -o LogLevel=ERROR \
        -o ServerAliveInterval=10 -o ServerAliveCountMax=6 \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        root@127.0.0.1 "$@"
}

# Commande dans la session graphique d'un compte (par son gestionnaire
# systemd), attendue jusqu'au bout. Les arguments sont protégés du shell de
# la VM, car ssh les recolle, et de systemd, qui remplace sinon « $$ » par
# « $ » et « ${VARIABLE} » par sa valeur (--expand-environment, systemd-run(1)).
in_session() {
    local user=$1
    shift
    vm "systemd-run --machine=$user@ --user --wait --pipe --quiet --expand-environment=no $(printf '%q ' "$@")"
}

# Application lancée dans la session graphique d'un compte, sans l'attendre.
launch_in_session() {
    local user=$1
    shift
    vm "systemd-run --machine=$user@ --user --collect --quiet --expand-environment=no $(printf '%q ' "$@")"
}

# Attend que la VM réponde en SSH après un nouveau démarrage.
wait_boot() {
    local old=$boot_id deadline=$((SECONDS + 900)) id
    while :; do
        kill -0 "$qemu_pid" 2> /dev/null || die "QEMU s'est arrêté"
        # Les échecs de connexion sont attendus tant que la VM démarre.
        if id=$(vm cat /proc/sys/kernel/random/boot_id 2> /dev/null) && [[ $id != "$old" ]]; then
            boot_id=$id
            return
        fi
        ((SECONDS < deadline)) || die "pas de réponse SSH 15 minutes après le démarrage"
        sleep 10
    done
}

# Commande au moniteur de QEMU : capture d'écran, touche du clavier…
monitor() {
    python3 - "$work/monitor.sock" "$1" << 'PY'
import socket, sys
sock = socket.socket(socket.AF_UNIX)
sock.settimeout(30)
sock.connect(sys.argv[1])

def until_prompt():
    data = b""
    while b"(qemu)" not in data:
        chunk = sock.recv(4096)
        if not chunk:
            sys.exit("moniteur QEMU fermé")
        data += chunk

until_prompt()  # bannière, puis invite « (qemu) »
sock.sendall(sys.argv[2].encode() + b"\n")
until_prompt()  # nouvelle invite : la commande est terminée
sock.close()
PY
}

# Clic de souris à la position (X, Y) de l'écran de la VM (1280x800), par le
# protocole QMP de QEMU (commande input-send-event) : la tablette USB de la VM
# donne un pointeur absolu, de 0 à 32767 sur chaque axe
# (https://www.qemu.org/docs/master/interop/qemu-qmp-ref.html).
click() {
    python3 - "$work/qmp.sock" "$1" "$2" << 'PY'
import json, socket, sys
sock = socket.socket(socket.AF_UNIX)
sock.settimeout(30)
sock.connect(sys.argv[1])
f = sock.makefile("rw")

def cmd(name, arguments=None):
    message = {"execute": name}
    if arguments:
        message["arguments"] = arguments
    f.write(json.dumps(message) + "\n")
    f.flush()
    while True:  # les événements asynchrones de QEMU sont ignorés
        reponse = json.loads(f.readline())
        if "return" in reponse:
            return
        if "error" in reponse:
            sys.exit(reponse["error"]["desc"])

def evenements(*liste):
    cmd("input-send-event", {"events": list(liste)})

json.loads(f.readline())  # message d'accueil de QMP
cmd("qmp_capabilities")
x = int(sys.argv[2]) * 32767 // 1280
y = int(sys.argv[3]) * 32767 // 800
evenements({"type": "abs", "data": {"axis": "x", "value": x}},
           {"type": "abs", "data": {"axis": "y", "value": y}})
evenements({"type": "btn", "data": {"down": True, "button": "left"}})
evenements({"type": "btn", "data": {"down": False, "button": "left"}})
PY
}

# Capture l'écran de la VM en PNG (commande screendump du moniteur de QEMU).
screenshot() {
    local file="$work/captures/$1.png"
    monitor "screendump $file -f png"
    [[ -s $file ]] || die "capture d'écran impossible : $file"
    echo "Capture : $file"
}

# Le compte a une session au premier plan (« active » pour logind). Une
# ancienne session restée ouverte hors du premier plan ne compte pas :
# l'écran n'en montre qu'une image figée, et polkit ne la traite pas comme
# active (vu le 2026-10-13, run 38365568996).
session_active() {
    local state
    state=$(vm loginctl show-user "$1" -p State --value 2> /dev/null) || return 1
    [[ $state == active ]]
}

# Le compte a son bureau Plasma, dans une session au premier plan.
desktop_ready() {
    vm pgrep -u "$1" -x plasmashell > /dev/null && session_active "$1"
}

# Attend le bureau Plasma d'un compte (par défaut, le compte de test), puis
# le capture.
wait_desktop() {
    local name=$1 user=${2:-ankhvm} deadline=$((SECONDS + 180))
    until desktop_ready "$user"; do
        if ((SECONDS >= deadline)); then
            screenshot "$name-echec"
            explain_session "$user"
            die "le bureau Plasma ne démarre pas pour le compte $user"
        fi
        sleep 5
    done
    sleep 20 # le temps que le bureau finisse de s'afficher
    screenshot "$name"
}

# Sessions du compte pour logind : la session graphique doit être active
# (au premier plan) et locale, sinon polkit refuse ce qu'il accorde à un
# administrateur dans sa session (diagnostic).
explain_session() {
    local user=$1 cmd
    for cmd in \
        'loginctl list-sessions --no-legend' \
        "loginctl show-user $user -p State -p Display -p Sessions" \
        "loginctl show-session \$(loginctl show-user $user -p Display --value) -p Active -p State -p Seat -p VTNr -p Type -p Class -p Service" \
        'cat /sys/class/tty/tty0/active' \
        "id $user"; do
        echo "--- $cmd"
        if ! vm "$cmd"; then
            echo "(commande en échec)"
        fi
    done
}

# Crée un compte de test. Ni verrouillage ni écran éteint pendant le test
# (sinon les captures montrent l'écran de verrouillage, puis un écran noir).
# Réglages locaux de la VM de test seulement (comme la clé SSH) : ils restent
# valables après chaque basculement.
# Le compte est administrateur (groupe wheel) dès sa création, comme celui
# que crée l'assistant (D-046) : polkit prend les groupes du programme qui
# demande, tels que D-Bus les voit, donc ceux de l'ouverture de sa session
# (src/polkitbackend/polkitbackendduktapeauthority.c de polkit 127). Un
# compte ajouté au groupe pendant sa session n'y est pas pour Flatpak.
add_test_account() {
    local user=$1 comment=$2
    vm "useradd -m -G wheel -c '$comment' $user &&
        install -d -o $user -g $user /home/$user/.config &&
        printf '[Daemon]\nAutolock=false\nLockOnResume=false\n' > /home/$user/.config/kscreenlockerrc &&
        printf '[AC][Display]\nDimDisplayWhenIdle=false\nTurnOffDisplayWhenIdle=false\n' > /home/$user/.config/powerdevilrc &&
        chown $user:$user /home/$user/.config/kscreenlockerrc /home/$user/.config/powerdevilrc"
}

# Connexion automatique d'un compte (par défaut, le compte de test). Elle est
# réglée pour les deux gestionnaires de connexion, car les étapes du test
# démarrent des images qui utilisent l'un ou l'autre : SDDM pour Ankh (D-043),
# Plasma Login pour l'image de base et les versions d'Ankh d'avant D-043.
# Plasma Login, dérivé de SDDM, lit la même section [Autologin] dans
# /etc/plasmalogin.conf ou /etc/plasmalogin.conf.d/
# (https://wiki.archlinux.org/title/Plasma_Login_Manager).
configure_autologin() {
    local user=${1:-ankhvm} session=${2:-plasma.desktop} dm dir
    dm=$(vm systemctl show -p Id --value display-manager.service)
    echo "Gestionnaire de connexion : $dm"
    case $dm in
        plasmalogin.service | sddm.service) ;;
        *) die "gestionnaire de connexion inattendu : $dm" ;;
    esac
    for dir in /etc/sddm.conf.d /etc/plasmalogin.conf.d; do
        vm "mkdir -p $dir && printf '[Autologin]\nUser=$user\nSession=$session\n' > $dir/ankh-vmtest.conf"
    done
    # Plasma Login ignore parfois le dossier .conf.d (https://bugs.kde.org/show_bug.cgi?id=522006) :
    # le fichier principal est écrit aussi s'il n'existe pas, ou s'il vient
    # déjà de ce test.
    if [[ $autologin_main == yes ]] || ! vm test -e /etc/plasmalogin.conf; then
        vm cp /etc/plasmalogin.conf.d/ankh-vmtest.conf /etc/plasmalogin.conf
        autologin_main=yes
    fi
    # Une session ouverte du compte survit à l'arrêt du gestionnaire de
    # connexion, hors du premier plan : elle est fermée, pour que la
    # connexion automatique en ouvre une nouvelle (voir desktop_ready).
    vm systemctl stop display-manager.service
    if vm loginctl show-user "$user" > /dev/null 2>&1; then
        vm loginctl terminate-user "$user"
    fi
    vm systemctl start display-manager.service
}

# Fin de l'assistant de premier démarrage, comme il la marque lui-même
# (README.md et src/bootutil/bootutil.cpp de https://invent.kde.org/plasma/plasma-setup) :
# fichier /etc/plasma-setup-done, et sa connexion automatique retirée. Sans
# cela, le gestionnaire de connexion rouvrirait l'assistant.
finish_setup() {
    vm "touch /etc/plasma-setup-done &&
        rm -f /etc/sddm.conf.d/99-plasma-setup.conf /etc/plasmalogin.conf.d/99-plasma-setup.conf"
}

# D-043 : l'écran de démarrage d'Ankh avec la saisie du mot de passe du
# disque, que la VM de test n'a pas (pas de LUKS). Plymouth est lancé à la
# main, l'écran de connexion arrêté le temps des captures, puis la demande de
# mot de passe affichée et quelques caractères tapés (plymouthd et plymouth
# ask-for-password, https://gitlab.freedesktop.org/plymouth/plymouth).
# Diagnostic visuel : un échec est affiché sans arrêter le test.
check_boot_screen() {
    local deadline
    log "Écran de démarrage d'Ankh et saisie du mot de passe du disque (D-043)"
    vm systemctl stop display-manager.service
    # Comme au vrai démarrage, aucune session ouverte (voir configure_autologin)
    if vm loginctl show-user ankhvm > /dev/null 2>&1; then
        vm loginctl terminate-user ankhvm
    fi
    sleep 5
    if vm 'plymouthd --mode=boot --tty=tty1 && plymouth show-splash'; then
        sleep 5
        screenshot 1-demarrage-ankh
        vm "systemd-run --unit=ankh-plymouth-mdp --collect --quiet plymouth ask-for-password --prompt='Mot de passe du disque chiffré'"
        sleep 3
        type_text ankh
        sleep 2
        screenshot 1-demarrage-mot-de-passe
        if ! vm 'plymouth quit'; then
            echo "(Plymouth : arrêt impossible)"
        fi
    else
        echo "(Plymouth : lancement à la main impossible, pas de capture du mot de passe)"
    fi
    vm systemctl start display-manager.service
    # La connexion automatique rouvre le bureau. Diagnostic seulement, comme
    # le reste de cet essai : le démarrage de l'étape 2 repart de zéro.
    deadline=$((SECONDS + 180))
    until desktop_ready ankhvm; do
        if ((SECONDS >= deadline)); then
            screenshot 1-bureau-apres-demarrage-test-echec
            echo "(pas de bureau actif 3 minutes après l'essai de l'écran de démarrage)"
            explain_session ankhvm
            return
        fi
        sleep 5
    done
    sleep 20
    screenshot 1-bureau-apres-demarrage-test
}

# Tape un texte au clavier de la VM, touche par touche (lettres minuscules
# et chiffres : noms des touches de la commande sendkey du moniteur de QEMU).
type_text() {
    local i
    for ((i = 0; i < ${#1}; i++)); do
        monitor "sendkey ${1:i:1}"
    done
}

# État de /boot avant un redémarrage qui doit appliquer une version préparée :
# montages empilés sur /boot, et unités qui le montent ou le gardent ouvert
# pour la finalisation par ostree à l'arrêt.
show_boot_state() {
    local cmd
    for cmd in \
        'rpm -q ostree systemd' \
        'findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS /boot' \
        'systemctl show -p Id,ActiveState,UnitFileState,FragmentPath boot.automount boot.mount ostree-finalize-staged.service ostree-finalize-staged-hold.service'; do
        echo "--- $cmd"
        if ! vm "$cmd"; then
            echo "(commande en échec)"
        fi
    done
}

reboot_vm() {
    vm systemd-run --on-active=2 systemctl reboot
    wait_boot
}

# Quand la version attendue n'a pas démarré : finalisation du déploiement
# préparé par ostree (faite à l'arrêt précédent), état des déploiements et
# place dans /boot, pour trouver la cause dans le journal de la CI.
explain_deployment() {
    local cmd
    log "Diagnostic : la version attendue n'a pas démarré"
    for cmd in \
        'journalctl -b -1 -o short-monotonic -u ostree-finalize-staged.service -u ostree-finalize-staged-hold.service -u boot.mount -u boot.automount --no-pager' \
        'journalctl -b -1 -n 60 --no-pager' \
        'bootc status' \
        'df -h /boot /sysroot' \
        'ls -la /boot/loader/entries /boot/ostree' \
        'du -sh /boot/ostree/*'; do
        echo "--- $cmd"
        if ! vm "$cmd"; then
            echo "(commande en échec)"
        fi
    done
}

# Champ de l'image démarrée dans « bootc status » (image.image ou imageDigest).
booted() {
    vm bootc status --format=json | jq -er ".status.booted.image.$1"
}

# Accepte un état « degraded » seulement si chaque service en échec est un
# échec connu de la VM, prouvé par son journal.
check_failed_units() {
    local units line unit journal
    local -a names=()
    units=$(vm systemctl list-units --state=failed --plain --no-legend)
    while read -r line; do
        if [[ -n ${line} ]]; then names+=("${line%% *}"); fi
    done <<< "${units}"
    for unit in "${names[@]}"; do
        journal=$(vm journalctl -b -u "${unit}" --no-pager -n 50)
        printf 'Service en échec : %s\n%s\n' "${unit}" "${journal}"
        [[ -n ${known_failures[${unit}]:-} && ${journal} == *"${known_failures[${unit}]}"* ]] ||
            die "service en échec non expliqué : ${unit}"
        echo "Échec connu, propre à la VM de test : ${unit}"
    done
}

check_boot() {
    local state ref digest
    if ! state=$(vm timeout 900 systemctl is-system-running --wait); then
        [[ ${state} == degraded ]] || die "démarrage incomplet (état : ${state:-inconnu})"
        check_failed_units
    fi
    [[ $(vm od -An -t u1 -j 4 -N 1 /sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c) =~ ^[[:space:]]*1$ ]] ||
        die "Secure Boot inactif"
    [[ $(vm cat /sys/fs/selinux/enforce) == 1 ]] || die "SELinux n'est pas en mode enforcing"
    [[ $(vm systemctl is-active firewalld) == active ]] || die "pare-feu (firewalld) inactif"
    ref=$(booted image.image)
    digest=$(booted imageDigest)
    echo "Démarrage complet ; Secure Boot, SELinux et pare-feu actifs."
    # Place dans /boot, où chaque version d'Ankh garde son noyau et son
    # initramfs (ici sur la partition btrfs du système, sans partition à lui).
    echo "/boot (utilisé, taille, %) : $(vm df -h --output=used,size,pcent /boot | tail -n 1)"
    echo "Image démarrée : $ref ($digest)"
}

# Vérifie que le système démarré contient bien les réglages d'Ankh.
check_ankh() {
    [[ $(vm readlink /etc/systemd/system/bootc-fetch-apply-updates.timer) == /dev/null ]] ||
        die "le timer de redémarrage automatique n'est pas masqué (D-010)"
}

# Vérifie le contenu propre à l'image installée (absent de l'image publiée
# tant que la PR n'est pas fusionnée) : version (D-028), Chrome et Firefox (D-023),
# pas de mise à jour automatique (D-031), habillage (D-033).
check_installed() {
    local chrome
    [[ $(booted version) == "$image_version" ]] || die "le système démarré ne porte pas la version $image_version (D-028)"
    chrome=$(vm google-chrome --version)
    [[ $chrome == "Google Chrome "* ]] || die "Chrome ne démarre pas : $chrome"
    echo "Chrome : $chrome"
    # rpm -q renvoie 1 quand le paquet est absent ; tout autre code est un échec.
    [[ $(vm 'rpm -q firefox > /dev/null; echo $?') == 1 ]] || die "Firefox est présent, ou son état est inconnu"
    # D-031 : rien ne se télécharge ni ne s'installe sans moi.
    [[ $(vm systemctl is-enabled rpm-ostreed-automatic.timer) == masked ]] ||
        die "le téléchargement automatique du système n'est pas désactivé (D-031)"
    # D-036, D-046 : VS Code dans le menu dès l'installation, par l'option
    # Dev (lien posé au démarrage par ankh-options.service ; sans choix
    # enregistré, toutes les options sont là). Le premier clic est testé une
    # fois, dans la session de test, par check_vscode.
    vm test -x /usr/libexec/ankh-vscode -a -L /usr/local/share/applications/ankh-vscode.desktop \
        -a -f /usr/local/share/applications/ankh-vscode.desktop ||
        die "VS Code absent du menu (D-036, D-046)"
    # D-050 : de même, Steam et la session « Ankh Console » par l'option Gaming.
    vm test -x /usr/libexec/ankh-flatpak -a -f /usr/local/share/applications/com.valvesoftware.Steam.desktop \
        -a -f /usr/local/share/wayland-sessions/ankh-console.desktop ||
        die "Steam ou la session « Ankh Console » absents (D-050)"
    # D-051 : ntsync chargé au démarrage avec l'option Gaming (choisie ici)
    vm test -c /dev/ntsync || die "ntsync n'est pas chargé alors que l'option Gaming est choisie (D-051)"
    # D-033 : le système s'appelle Ankh, jusque dans le menu de démarrage
    # (titre écrit par ostree à partir de PRETTY_NAME).
    # shellcheck disable=SC2016 # variables lues dans la VM
    [[ $(vm '. /etc/os-release && echo "$NAME $ID"') == "Ankh fedora" ]] ||
        die "le système ne s'appelle pas Ankh, ou son ID n'est plus fedora (D-033)"
    vm "grep -q '^title Ankh ' /boot/loader/entries/*.conf" ||
        die "le menu de démarrage n'affiche pas Ankh (D-033)"
    [[ $(vm cat /proc/sys/kernel/hostname) == ankh ]] || die "la machine ne s'appelle pas « ankh » (D-033)"
    # D-034 : écran de démarrage graphique (« rhgb », donné par l'image).
    vm grep -qw rhgb /proc/cmdline || die "le noyau n'a pas reçu « rhgb » : pas d'écran de démarrage (D-034)"
    # D-004 : /boot n'est pas monté automatiquement par-dessus le montage d'ostree.
    [[ $(vm systemctl is-enabled boot.automount) == masked ]] ||
        die "le montage automatique de /boot n'est pas masqué (D-004)"
    # D-035 : VLC et OnlyOffice présents dès l'installation, LibreOffice absent.
    vm rpm -q vlc onlyoffice-desktopeditors || die "VLC ou OnlyOffice absent (D-035)"
    [[ -z $(vm "rpm -qa 'libreoffice*'") ]] || die "LibreOffice est présent (D-035)"
}

# Lance une application dans la session du compte de test, par la commande
# de son lanceur principal (qui porte son nom), puis la capture.
capture_app() {
    local name=$1 app=$2 desktop exe
    desktop=/usr/share/applications/$app.desktop
    exe=$(vm "sed -n 's/^Exec=\([^ ]*\).*/\1/p' $desktop | head -n 1")
    echo "$name : $desktop ($exe)"
    vm systemd-run --machine=ankhvm@ --user --collect --quiet "$exe"
    sleep 30
    screenshot "$name"
}

# D-036 : premier lancement de VS Code depuis le menu, comme un clic : une
# fenêtre montre la préparation de l'environnement de dev (téléchargement du
# conteneur, extensions), puis VS Code s'ouvre. Captures des deux moments.
check_vscode() {
    local deadline=$((SECONDS + 2400)) next=$((SECONDS + 300)) journal=/home/ankhvm/.cache/ankh/preparation-dev.log
    # Lancé comme KDE lance une application du menu : un service avec
    # ExitType=cgroup, qui ne tue pas ce que le lanceur a démarré quand il se
    # termine (src/gui/systemd/systemdprocessrunner.cpp de
    # https://invent.kde.org/frameworks/kio). Sans cela, systemd arrêtait le
    # conteneur et VS Code deux secondes après leur démarrage.
    vm systemd-run --machine=ankhvm@ --user --unit=ankh-vscode-premier-clic --quiet \
        --property=Type=simple --property=ExitType=cgroup /usr/libexec/ankh-vscode
    sleep 60
    screenshot 1-vscode-preparation
    until vm pgrep -u ankhvm -f /usr/share/code/code > /dev/null; do
        if ((SECONDS >= deadline)); then
            screenshot 1-vscode-echec
            explain_vscode "$journal"
            die "VS Code ne s'est pas ouvert 40 minutes après le premier clic (D-036)"
        fi
        if ((SECONDS >= next)); then
            next=$((SECONDS + 300))
            echo "Préparation en cours, fin du journal :"
            if ! vm "tail -n 3 $journal"; then
                echo "(journal de préparation absent)"
            fi
        fi
        sleep 15
    done
    sleep 45
    screenshot 1-vscode
    echo "VS Code ouvert au premier clic, environnement de dev préparé"
    show_windows
}

# Script de KWin lancé dans la session d'un compte : kwin_script COMPTE NOM
# ÉTIQUETTE SCRIPT. Ses lignes console.warn() qui portent l'étiquette sont
# lues dans le journal de la session, puis affichées.
kwin_script() {
    local user=$1 nom=$2 etiquette=$3 script=$4 debut
    debut=$(vm date +%s)
    # vm() ne lit pas l'entrée standard (ssh -n) : le script passe par la
    # commande, protégé pour le shell de la VM.
    vm "printf '%s\n' $(printf '%q' "$script") > /tmp/$nom.js && chmod 0644 /tmp/$nom.js"
    if in_session "$user" busctl --user call org.kde.KWin /Scripting org.kde.kwin.Scripting loadScript ss "/tmp/$nom.js" "$nom" &&
        in_session "$user" busctl --user call org.kde.KWin /Scripting org.kde.kwin.Scripting start; then
        sleep 3
        if ! vm "journalctl --no-pager -b --since=@$debut _UID=$(vm id -u "$user") --grep $etiquette --output cat"; then
            echo "($nom : rien dans le journal)"
        fi
        if ! in_session "$user" busctl --user call org.kde.KWin /Scripting org.kde.kwin.Scripting unloadScript s "$nom"; then
            echo "($nom : script de KWin non retiré)"
        fi
    else
        echo "($nom : script de KWin impossible à charger)"
    fi
}

# Fenêtres ouvertes vues par KWin : classe, nom et fichier .desktop. La barre
# relie une fenêtre à son lanceur par ces valeurs (windowUrlFromMetadata,
# libtaskmanager/tasktools.cpp de plasma-workspace) ; diagnostic seulement.
show_windows() {
    kwin_script ankhvm ankh-fenetres ANKH-FENETRE 'for (const w of workspace.windowList()) {
    if (w.normalWindow) {
        console.warn("ANKH-FENETRE classe=" + w.resourceClass + " nom=" + w.resourceName +
                     " desktop=" + w.desktopFileName + " titre=" + w.caption);
    }
}'
}

# Rend active, dans la session du compte de test, la fenêtre dont le nom de
# fichier .desktop vu par KWin contient $1 : le clavier de la VM va vers elle.
# Sa place à l'écran est affichée (diagnostic).
activate_window() {
    kwin_script ankhvm ankh-activer ANKH-ACTIVEE "for (const w of workspace.windowList()) {
    if (String(w.desktopFileName).includes('$1')) {
        workspace.activeWindow = w;
        const g = w.frameGeometry;
        console.warn('ANKH-ACTIVEE ' + w.desktopFileName + ' titre=' + w.caption + ' place=' + g.x + ',' + g.y + ' ' + g.width + 'x' + g.height);
    }
}"
}

# Quand VS Code ne s'ouvre pas : journal de la préparation, sortie du
# lanceur, et conteneurs du compte de test.
explain_vscode() {
    local cmd
    log "Diagnostic : VS Code ne s'est pas ouvert"
    for cmd in \
        "tail -n 60 $1" \
        'journalctl --no-pager -n 60 _SYSTEMD_USER_UNIT=ankh-vscode-premier-clic.service' \
        'systemd-run --machine=ankhvm@ --user --wait --pipe --quiet podman ps -a'; do
        echo "--- $cmd"
        if ! vm "$cmd"; then
            echo "(commande en échec)"
        fi
    done
}

# D-028 : ouvre Discover sur la page des mises à jour, le capture, puis
# affiche ce qu'il a écrit dans son journal. La fenêtre « Update Issue » ne
# dit pas quelle source de Discover a échoué : système (rpm-ostree, qui
# interroge le registre avec skopeo), Flatpak, micrologiciels (fwupd), KDE
# Store ou avis. Chacune écrit son erreur dans le journal
# (libdiscover/backends de https://invent.kde.org/plasma/discover).
open_discover() {
    local name=$1 unit=ankh-test-discover-${1%%-*} since ref cmd
    since=$(vm date +%s)
    # ssh recolle les arguments : la règle de journalisation est protégée du
    # shell de la VM. Les messages de détail de la source « système » sont
    # ajoutés aux avertissements, toujours écrits.
    vm "systemd-run --machine=ankhvm@ --user --collect --quiet --unit=$unit \
        --property=Type=simple --property=ExitType=cgroup \
        --setenv=QT_LOGGING_RULES='org.kde.plasma.libdiscover.backend.rpm-ostree.debug=true' \
        plasma-discover --mode update"
    sleep 60
    screenshot "$name"
    log "Journal de Discover et des services qu'il interroge ($name)"
    for cmd in \
        "journalctl --no-pager -o short-monotonic -n 300 _SYSTEMD_USER_UNIT=$unit.service | cut -c 1-400" \
        "journalctl --no-pager -o short-monotonic --since=@$since -u polkit.service -u fwupd.service -u rpm-ostreed.service -u flatpak-system-helper.service" \
        "rpm -qa 'plasma-discover*' skopeo fwupd flatpak" \
        'rpm-ostree status --booted' \
        'flatpak remotes --system --show-details' \
        'id ankhvm'; do
        echo "--- $cmd"
        if ! vm "$cmd"; then
            echo "(commande en échec)"
        fi
    done
    # La vérification de Discover pour le système, refaite à la main, au nom
    # du compte de test : version d'Ankh publiée dans le registre.
    ref=$(booted image.image)
    echo "--- skopeo inspect --no-tags docker://$ref (version publiée)"
    if ! vm "systemd-run --machine=ankhvm@ --user --wait --pipe --quiet skopeo inspect --no-tags docker://$ref" |
        jq -r '.Labels["org.opencontainers.image.version"]'; then
        echo "(commande en échec)"
    fi
}

# Réglage de KDE tel que le voit la session d'un compte, comparé à la valeur
# attendue : identity_setting COMPTE DESCRIPTION VALEUR OPTIONS_DE_KREADCONFIG6...
# Ordre des dossiers de réglages de la session Plasma : ~/.config, puis
# ~/.config/kdedefaults (réglages du thème global, ajoutés par
# startkde/startplasma.cpp de plasma-workspace), puis /etc/xdg et ceux de
# Fedora (plasma-workspace/env/env.sh de kde-settings-plasma).
identity_setting() {
    local user=$1 description=$2 valeur=$3 lu
    shift 3
    lu=$(in_session "$user" env "XDG_CONFIG_DIRS=/home/$user/.config/kdedefaults:/etc/xdg:/usr/share/kde-settings/kde-profile/default/xdg" \
        kreadconfig6 "$@")
    [[ $lu == "$valeur" ]] || die "$description : « $lu » au lieu de « $valeur » (D-037, D-039)"
    echo "$description : $lu"
}

# Ferme une application de la session d'un compte, si elle est ouverte.
close_app() {
    local user=$1 name=$2
    if vm pgrep -u "$user" -x "$name" > /dev/null; then
        vm pkill -u "$user" -x "$name"
        sleep 2
    fi
}

# D-046 : la page « Choisissez vos outils » de l'assistant, deux pages après
# « Bienvenue dans Ankh » (puis la langue). Elle applique son choix par défaut
# (Dev) dès qu'elle s'affiche, par le service ankh-options@dev, que le compte
# de l'assistant peut démarrer sans mot de passe (règle polkit d'Ankh), et
# lui seul. Le bouton « Next » est au même endroit sur chaque page (captures).
check_options_assistant() {
    click 835 646
    sleep 5
    click 835 646
    sleep 10
    screenshot 1-assistant-options
    # ssh recolle les arguments : le motif, qui contient une espace, est
    # protégé pour le shell de la VM.
    if ! vm "grep -qx 'OPTIONS=dev gaming' /etc/ankh/options"; then
        # shellcheck disable=SC2016 # variables lues dans la VM
        if ! vm 'cat /etc/ankh/options; journalctl -b --no-pager -o cat -u "ankh-options@*";
            journalctl -b --no-pager -o cat _UID="$(id -u plasma-setup)" | tail -n 30'; then
            echo "(diagnostic des options : rien trouvé)"
        fi
        die "la page de l'assistant n'a pas enregistré le choix des options (D-046)"
    fi
    echo "Choix enregistré par la page de l'assistant : $(vm grep -x 'OPTIONS=.*' /etc/ankh/options)"
    if vm runuser -u plasma-setup -- systemctl --no-ask-password start ankh-options.service; then
        die "le compte de l'assistant a pu démarrer un autre service que ankh-options@ (D-046)"
    fi
    vm runuser -u plasma-setup -- systemctl --no-ask-password start ankh-options@simple.service ||
        die "le compte de l'assistant ne peut pas appliquer un choix (D-046)"
    if vm test -e /usr/local/share/applications/ankh-vscode.desktop; then
        die "VS Code reste dans le menu avec Simple seule (D-046)"
    fi
    vm systemctl start ankh-options@dev_gaming.service
    vm test -e /usr/local/share/applications/ankh-vscode.desktop -a -e /usr/local/share/applications/com.valvesoftware.Steam.desktop ||
        die "VS Code ou Steam ne reviennent pas dans le menu avec Dev et Gaming (D-046, D-050)"
    echo "Options : Simple seule retire VS Code du menu, Dev et Gaming les remettent ; le compte de l'assistant ne démarre que ankh-options@"
}

# Quand « Options d'Ankh » ne fait pas ce qui est attendu : choix enregistré,
# menu, et messages de la fenêtre, de pkexec et de polkit.
explain_options() {
    local cmd
    log "Diagnostic : Options d'Ankh"
    for cmd in \
        'cat /etc/ankh/options' \
        'ls -la /usr/local/share/applications/' \
        "journalctl --no-pager -b -o cat _UID=$(vm id -u ankhvm) | grep -iE 'plasmawindowed|org.ankh|ankh-options|pkexec|polkit|qml' | tail -n 40" \
        'journalctl --no-pager -b -o cat -u polkit.service | tail -n 20' \
        'pgrep -a -u ankhvm -f "plasmawindowed|polkit|pkexec|ankh-options"'; do
        echo "--- $cmd"
        if ! vm "$cmd"; then
            echo "(commande en échec)"
        fi
    done
}

# Applications épinglées dans la barre du compte de test, lues dans Plasma
# par son script (méthode evaluateScript, comme ankh-options-reglages).
pinned_apps() {
    in_session ankhvm busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell evaluateScript s \
        'for (const p of panels()) { for (const w of p.widgets("org.kde.plasma.icontasks")) { w.currentConfigGroup = ["General"]; print(w.readConfig("launchers", []).join(",")); } }'
}

# Choix d'options fait au clavier dans la fenêtre « Options d'Ankh » ouverte,
# comme on le ferait : Espace sur la première case (Complète, qui a le clavier
# à l'ouverture), Entrée pour appliquer, puis le mot de passe du compte de test
# dans la fenêtre de polkit. Captures : la fenêtre juste avant d'appliquer,
# puis la fenêtre du mot de passe. Attend ensuite que le choix enregistré soit
# $3 (une minute au plus).
choose_options() {
    local avant=$1 mot_de_passe=$2 attendu=$3 deadline
    activate_window org.kde.plasmawindowed
    monitor 'sendkey spc'
    sleep 2
    screenshot "$avant"
    monitor 'sendkey ret'
    sleep 8
    activate_window polkit
    screenshot "$mot_de_passe"
    type_text ankhtest42
    monitor 'sendkey ret'
    deadline=$((SECONDS + 60))
    until [[ $(vm "sed -n 's/^OPTIONS=//p' /etc/ankh/options") == "$attendu" ]]; do
        if ((SECONDS >= deadline)); then
            screenshot "$avant-echec"
            explain_options
            die "« Options d'Ankh » n'a pas enregistré le choix « $attendu » (D-046)"
        fi
        sleep 5
    done
    # Le temps que le menu, la barre et la fenêtre suivent
    sleep 15
}

# D-046 : « Options d'Ankh », dans la Configuration du système (catégorie
# Système). Sa fenêtre (widget org.ankh.options, ouvert par plasmawindowed)
# est capturée, puis utilisée au clavier : Complète décochée (Dev et Gaming
# retirées), puis recochée. Chaque fois, le mot de passe d'un administrateur
# est demandé par polkit (pkexec), et le menu et la barre suivent (VS Code et
# Steam). Le compte de test est administrateur (voir add_test_account) : son
# mot de passe est donné ici, pour la fenêtre de polkit.
check_options_reglages() {
    local user=ankhvm epinglees
    vm "echo 'ankhvm:ankhtest42' | chpasswd"
    # VS Code, ouvert par check_vscode, cacherait la fenêtre
    close_app "$user" code
    launch_in_session "$user" systemsettings ankh-options
    sleep 20
    screenshot 1-options-reglages
    if ! vm pgrep -u "$user" -x plasmawindowed > /dev/null; then
        explain_options
        die "la fenêtre « Options d'Ankh » ne s'est pas ouverte (D-046)"
    fi
    show_windows
    if ! epinglees=$(pinned_apps); then
        die "barre du compte de test illisible"
    fi
    echo "Barre avant : $epinglees"

    log "Options d'Ankh : Dev et Gaming retirées"
    choose_options 1-options-reglages-simple 1-options-mot-de-passe ""
    screenshot 1-options-reglages-fait
    if vm test -e /usr/local/share/applications/ankh-vscode.desktop -o -e /usr/local/share/applications/com.valvesoftware.Steam.desktop; then
        die "VS Code ou Steam restent dans le menu après le retrait de Dev et Gaming (D-046, D-050)"
    fi
    if ! epinglees=$(pinned_apps); then
        die "barre du compte de test illisible"
    fi
    echo "Barre après le retrait : $epinglees"
    [[ $epinglees != *ankh-vscode.desktop* && $epinglees != *com.valvesoftware.Steam.desktop* ]] ||
        die "VS Code ou Steam restent épinglés dans la barre après le retrait (D-046, D-050)"
    vm test ! -e /sys/module/ntsync || die "ntsync reste chargé après le retrait de Gaming (D-051)"
    close_app "$user" plasmawindowed
    close_app "$user" systemsettings
    screenshot 1-options-barre-sans-dev
    # La fenêtre propose alors de supprimer l'environnement de dev (capture
    # 1-options-reglages-fait) : la commande de son bouton « Supprimer » est
    # essayée ici. Le conteneur et son image doivent partir.
    in_session "$user" /usr/libexec/ankh-dev supprimer
    if in_session "$user" podman container exists ankh-dev ||
        in_session "$user" podman image exists ghcr.io/patrickchoumi/ankh-dev:latest; then
        die "l'environnement de dev existe encore après « ankh-dev supprimer » (D-046)"
    fi
    echo "Environnement de dev supprimé : conteneur et image"

    log "Options d'Ankh : Dev et Gaming remises"
    launch_in_session "$user" plasmawindowed org.ankh.options
    sleep 15
    choose_options 1-options-reglages-dev 1-options-mot-de-passe-dev "dev gaming"
    screenshot 1-options-reglages-dev-fait
    vm test -e /usr/local/share/applications/ankh-vscode.desktop -a -e /usr/local/share/applications/com.valvesoftware.Steam.desktop ||
        die "VS Code ou Steam ne reviennent pas dans le menu (D-046, D-050)"
    if ! epinglees=$(pinned_apps); then
        die "barre du compte de test illisible"
    fi
    echo "Barre après le retour : $epinglees"
    [[ $epinglees == *ankh-vscode.desktop* && $epinglees == *com.valvesoftware.Steam.desktop* ]] ||
        die "VS Code ou Steam ne sont pas épinglés dans la barre à leur retour (D-046, D-050)"
    vm test -c /dev/ntsync || die "ntsync n'est pas chargé au retour de Gaming (D-051)"
    # Échap ferme la fenêtre
    activate_window org.kde.plasmawindowed
    monitor 'sendkey esc'
    sleep 3
    if vm pgrep -u "$user" -x plasmawindowed > /dev/null; then
        die "Échap ne ferme pas la fenêtre « Options d'Ankh » (D-046)"
    fi
    echo "Options d'Ankh : Dev et Gaming retirées puis remises avec le mot de passe, menu, barre et ntsync à jour"
}

# Quand une application Gaming (Steam par défaut) ou la session « Ankh
# Console » ne font pas ce qui est attendu : journal de la préparation,
# applications Flatpak, messages de la session.
explain_gaming() {
    local application=${1:-com.valvesoftware.Steam} cmd
    log "Diagnostic : option Gaming"
    for cmd in \
        "tail -n 60 /home/ankhvm/.cache/ankh/preparation-$application.log" \
        'flatpak list --system --columns=ref' \
        "journalctl --no-pager -b -o cat _UID=$(vm id -u ankhvm) | grep -iE 'steam|flatpak|kwin|ankh-console|ankh-flatpak' | tail -n 60" \
        'journalctl --no-pager -b -o cat -u sddm.service | tail -n 30' \
        'pgrep -a -u ankhvm -f "kwin|steam|flatpak|konsole"' \
        'journalctl --no-pager -b -o cat -u polkit.service | tail -n 20'; do
        echo "--- $cmd"
        if ! vm "$cmd"; then
            echo "(commande en échec)"
        fi
    done
    explain_session ankhvm
}

# Attend qu'une application Gaming tourne (flatpak ps). Sa préparation est
# alors finie : ankh-flatpak installe les outils du jeu en Flatpak après
# l'application, et ne l'ouvre qu'ensuite (vu le 2026-10-14 : Gamescope
# encore en téléchargement quand le test, trop tôt, l'a cherché).
wait_running() { # $1 : compte, $2 : application, $3 : nom des captures
    local user=$1 application=$2 nom=$3 deadline=$((SECONDS + 300)) instances
    while :; do
        if instances=$(in_session "$user" flatpak ps --columns=application) &&
            [[ $'\n'$instances$'\n' == *$'\n'$application$'\n'* ]]; then
            return
        fi
        if ((SECONDS >= deadline)); then
            screenshot "1-$nom-echec"
            explain_gaming "$application"
            die "$application ne tourne pas 5 minutes après sa préparation (D-050)"
        fi
        sleep 5
    done
}

# D-050 : premier lancement de Steam depuis le menu, comme un clic (voir
# check_vscode) : une fenêtre montre son téléchargement depuis Flathub, puis
# celui des outils du jeu en Flatpak, et Steam s'ouvre ; il se met alors à
# jour lui-même, puis demande de se connecter. Le compte de test est
# administrateur, comme le compte créé par l'assistant : Flatpak installe
# alors pour toute la machine sans mot de passe (règle polkit de Flatpak pour
# le groupe wheel, si la session est active et locale).
check_steam() {
    local user=ankhvm deadline=$((SECONDS + 1800)) couche app nom reponse
    log "Premier clic sur Steam (D-050)"
    # Fenêtres laissées ouvertes par check_identity
    for app in dolphin konsole systemsettings ksplashqml; do
        close_app "$user" "$app"
    done
    # polkit est interrogé comme Flatpak le fait (system-helper/flatpak-system-helper.c) :
    # pour le programme qui appelle, désigné par son nom sur le bus système.
    # polkit prend alors les groupes de ce programme (voir add_test_account)
    # et le rattache à la session graphique du compte, même lancé hors de la
    # session par le menu (src/polkitbackend/polkitbackendsessionmonitor-systemd.c
    # de https://github.com/polkit-org/polkit). Le programme interrogé est le
    # bureau (plasmashell) : comme une application du menu, il tourne dans le
    # gestionnaire systemd du compte. Réponse attendue : autorisé, sans question.
    nom=$(vm "busctl --system list --unique --no-legend | awk '\$3 == \"plasmashell\" && \$4 == \"$user\" { print \$1; exit }'")
    [[ $nom == :* ]] || die "plasmashell du compte de test absent du bus système"
    if ! reponse=$(vm "busctl --system call org.freedesktop.PolicyKit1 /org/freedesktop/PolicyKit1/Authority org.freedesktop.PolicyKit1.Authority CheckAuthorization '(sa{sv})sa{ss}us' system-bus-name 1 name s $nom org.freedesktop.Flatpak.app-install 0 0 ''"); then
        die "polkit n'a pas répondu pour plasmashell ($nom)"
    fi
    echo "polkit, org.freedesktop.Flatpak.app-install pour plasmashell ($nom) : $reponse"
    if [[ $reponse != "(bba{ss}) true false"* ]]; then
        explain_session "$user"
        die "polkit demanderait un mot de passe à l'administrateur dans sa session pour installer Steam (D-050)"
    fi
    vm systemd-run --machine=$user@ --user --unit=ankh-steam-premier-clic --quiet \
        --property=Type=simple --property=ExitType=cgroup /usr/libexec/ankh-flatpak com.valvesoftware.Steam
    sleep 45
    screenshot 1-steam-preparation
    until vm flatpak info --system com.valvesoftware.Steam > /dev/null 2>&1; do
        if ((SECONDS >= deadline)); then
            screenshot 1-steam-echec
            explain_gaming
            die "Steam ne s'est pas préparé 30 minutes après le premier clic (D-050)"
        fi
        sleep 15
    done
    wait_running "$user" com.valvesoftware.Steam steam
    for couche in MangoHud gamescope; do
        if ! vm flatpak info --system "org.freedesktop.Platform.VulkanLayer.$couche//26.08" > /dev/null; then
            explain_gaming
            die "$couche en Flatpak absent après la préparation de Steam (D-050)"
        fi
    done
    echo "Steam préparé, avec MangoHud et Gamescope en Flatpak"
    # D-051 : Proton trouve ntsync depuis Steam en Flatpak (--device=all)
    in_session "$user" flatpak run --command=test com.valvesoftware.Steam -c /dev/ntsync ||
        die "ntsync n'est pas visible depuis Steam en Flatpak (D-051)"
    echo "ntsync : visible depuis Steam en Flatpak"
    sleep 180
    screenshot 1-steam
    show_windows
    if ! in_session "$user" flatpak kill com.valvesoftware.Steam; then
        echo "(Steam ne tournait plus)"
    fi
    sleep 5
}

# D-041, D-050 : premier clic sur les sept autres applications de l'option
# Gaming, comme pour Steam (check_steam) : préparation, puis l'application
# s'ouvre par sa propre entrée du menu. Pour chacune : elle doit tourner
# (flatpak ps), sa capture, puis les outils du jeu en Flatpak préparés pour
# sa version (lignes de son journal de préparation). Plusieurs Go depuis
# Flathub : seulement avec ANKH_VM_GAMING_COMPLET=1 (entrée « gaming_complet »
# du workflow, et chaque lundi).
check_gaming_apps() {
    local user=ankhvm application court deadline
    local applications=(com.heroicgameslauncher.hgl net.lutris.Lutris com.usebottles.bottles
        com.vysp3r.ProtonPlus com.github.Matoking.protontricks com.discordapp.Discord com.obsproject.Studio)
    local -A noms=([com.heroicgameslauncher.hgl]=heroic [net.lutris.Lutris]=lutris
        [com.usebottles.bottles]=bottles [com.vysp3r.ProtonPlus]=protonplus
        [com.github.Matoking.protontricks]=protontricks [com.discordapp.Discord]=discord
        [com.obsproject.Studio]=obs)
    log "Premier clic sur les sept autres applications Gaming (D-041, D-050)"
    for application in "${applications[@]}"; do
        court=${noms[$application]}
        echo "--- $application"
        vm systemd-run --machine=$user@ --user --unit="ankh-premier-clic-$court" --quiet \
            --property=Type=simple --property=ExitType=cgroup /usr/libexec/ankh-flatpak "$application"
        deadline=$((SECONDS + 1200))
        until vm flatpak info --system "$application" > /dev/null 2>&1; do
            if ((SECONDS >= deadline)); then
                screenshot "1-gaming-$court-echec"
                explain_gaming "$application"
                die "$application ne s'est pas préparé 20 minutes après le premier clic (D-050)"
            fi
            sleep 15
        done
        # L'application tourne, ouverte par sa propre entrée du menu
        wait_running "$user" "$application" "gaming-$court"
        sleep 60
        screenshot "1-gaming-$court"
        if ! vm "grep -E 'Outils du jeu|déjà là|existe pas encore' /home/$user/.cache/ankh/preparation-$application.log"; then
            echo "(aucune ligne sur les outils du jeu dans le journal de préparation)"
        fi
        if ! in_session "$user" flatpak kill "$application"; then
            echo "($application ne tournait plus)"
        fi
        sleep 5
    done
    echo "Les sept autres applications Gaming se préparent au premier clic et s'ouvrent"
}

# D-050 : session « Ankh Console », ouverte comme si on la choisissait sur
# l'écran de connexion (connexion automatique dans cette session) : KWin
# seul, puis Steam en plein écran. La session doit démarrer ; ce que Steam
# affiche dans une VM sans carte graphique est un diagnostic. Le compte de
# test retrouve ensuite sa session Plasma.
check_console() {
    local user=ankhvm deadline
    log "Session « Ankh Console » (D-050)"
    configure_autologin "$user" ankh-console.desktop
    deadline=$((SECONDS + 180))
    until vm "pgrep -u $user -f 'kwin_wayland.*--exit-with-session'" > /dev/null && session_active "$user"; do
        if ((SECONDS >= deadline)); then
            screenshot 1-console-echec
            explain_gaming
            die "la session « Ankh Console » ne démarre pas (D-050)"
        fi
        sleep 5
    done
    echo "Session « Ankh Console » : KWin seul est démarré, au premier plan"
    sleep 150
    screenshot 1-console
    if vm pgrep -u "$user" -f com.valvesoftware.Steam > /dev/null; then
        echo "Steam tourne dans la session « Ankh Console »"
    else
        echo "(Steam ne tourne pas dans la session « Ankh Console »)"
        explain_gaming
    fi
    if ! in_session "$user" flatpak kill com.valvesoftware.Steam; then
        echo "(Steam ne tournait plus)"
    fi
    configure_autologin "$user"
    wait_desktop 1-bureau-apres-console
}

# D-037 et D-039 : l'interface d'Ankh, appliquée par défaut au compte de
# test à sa première session. Vérifie ce que Plasma a réellement appliqué
# (réglages lus dans la session : ceux de l'image, puis ceux du thème global
# écrits dans ~/.config/kdedefaults), puis capture le menu, Dolphin,
# Konsole et les réglages des couleurs.
check_identity() {
    local user=ankhvm
    log "Interface d'Ankh dans la session du compte de test (D-037, D-039)"
    identity_setting "$user" "Jeu de couleurs" Ankh --group General --key ColorScheme
    identity_setting "$user" "Thème global" org.fedoraproject.fedoradark.desktop --group KDE --key LookAndFeelPackage
    identity_setting "$user" "Icônes" breeze-dark --group Icons --key Theme
    identity_setting "$user" "Police de l'interface" 'Inter,10,-1,5,50,0,0,0,0,0' --group General --key font
    identity_setting "$user" "Opacité des menus" 85 --file breezerc --group Style --key MenuOpacity
    identity_setting "$user" "Profil Konsole" Ankh.profile --file konsolerc --group 'Desktop Entry' --key DefaultProfile
    identity_setting "$user" "Écran de chargement" org.fedoraproject.fedoradark.desktop --file ksplashrc --group KSplash --key Theme
    identity_setting "$user" "Recherche flottante (D-042)" true --file krunnerrc --group General --key FreeFloating
    # D-042 : l'image de compte d'Ankh, enregistrée auprès d'AccountsService
    # à la première session, pour l'écran de connexion.
    local uid icone
    uid=$(vm id -u "$user")
    icone=$(vm busctl --json=short get-property org.freedesktop.Accounts "/org/freedesktop/Accounts/User$uid" \
        org.freedesktop.Accounts.User IconFile | jq -r .data)
    [[ $icone == "/var/lib/AccountsService/icons/$user" ]] || die "image de compte non enregistrée : « $icone » (D-042)"
    echo "Image de compte : $icone"
    # Le flou de KWin est éteint par défaut sans carte graphique (rendu
    # logiciel, BlurEffect::enabledByDefault de src/plugins/blur/blur.cpp,
    # https://invent.kde.org/plasma/kwin) : il est allumé pour ce compte de
    # test, pour que les captures montrent ce qu'affiche une vraie machine.
    # Le réglage garde le flou allumé ; l'effet est aussi chargé tout de suite
    # (interface org.kde.kwin.Effects, src/org.kde.kwin.Effects.xml de KWin).
    echo "Rendu de KWin : $(in_session "$user" busctl --user get-property org.kde.KWin /Compositor org.kde.kwin.Compositing compositingType)"
    in_session "$user" kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    if in_session "$user" busctl --user call org.kde.KWin /Effects org.kde.kwin.Effects loadEffect s blur | grep -qx 'b true'; then
        echo "Flou de KWin : chargé"
    else
        echo "Flou de KWin : impossible à charger dans cette VM (pris en charge : $(in_session "$user" busctl --user call org.kde.KWin /Effects org.kde.kwin.Effects isEffectSupported s blur))"
    fi
    sleep 5
    in_session "$user" busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell activateLauncherMenu
    sleep 5
    screenshot 1-menu
    monitor 'sendkey esc'
    launch_in_session "$user" dolphin "/home/$user"
    sleep 15
    screenshot 1-dolphin
    launch_in_session "$user" konsole
    sleep 10
    screenshot 1-konsole
    launch_in_session "$user" systemsettings kcm_colors
    sleep 20
    screenshot 1-reglages-couleurs
    # Écran de verrouillage : verrouillé puis déverrouillé par logind, que
    # l'écran de verrouillage de KDE écoute (le compte de test n'a pas de mot
    # de passe à taper).
    # D-042 : recherche au milieu de l'écran (Alt+Espace), comme Spotlight.
    in_session "$user" busctl --user call org.kde.krunner /App org.kde.krunner.App query s code
    sleep 5
    screenshot 1-recherche
    monitor 'sendkey esc'
    # D-042 : la page « Raccourcis utiles » de l'accueil de KDE, ouverte seule
    # (l'accueil n'a qu'une fenêtre : celle de la première session est fermée).
    close_app "$user" plasma-welcome
    launch_in_session "$user" plasma-welcome --pages 01-Raccourcis.qml
    sleep 10
    screenshot 1-accueil-raccourcis
    close_app "$user" plasma-welcome
    # D-042 : le thème « Ankh Clair », appliqué le temps d'une capture, puis
    # retour au thème sombre par défaut.
    # Les fenêtres ouvertes sont masquées (bureau dégagé) pour que le fond
    # clair se voie autour de Dolphin.
    in_session "$user" plasma-apply-lookandfeel -a org.fedoraproject.fedoralight.desktop
    sleep 10
    in_session "$user" busctl --user call org.kde.KWin /KWin org.kde.KWin showDesktop b true
    sleep 3
    launch_in_session "$user" dolphin "/home/$user"
    sleep 10
    screenshot 1-theme-clair
    in_session "$user" plasma-apply-lookandfeel -a org.fedoraproject.fedoradark.desktop
    sleep 10
    vm loginctl lock-sessions
    sleep 10
    # Un clic fait apparaître l'image du compte et le bouton pour déverrouiller.
    click 40 40
    sleep 3
    screenshot 1-ecran-de-verrouillage
    vm loginctl unlock-sessions
    sleep 5
    # Écran de chargement de la session, rejoué en mode test (il se ferme seul
    # après 6 secondes : ksplash/ksplashqml/splashapp.cpp de plasma-workspace).
    launch_in_session "$user" ksplashqml --test
    sleep 3
    screenshot 1-ecran-de-chargement
    sleep 5
}

((EUID == 0)) || die "à lancer en root (podman de root, disque en boucle, KVM)"
[[ -e /dev/kvm ]] || die "/dev/kvm absent : KVM est nécessaire"
for f in OVMF_CODE_4M.secboot.fd OVMF_VARS_4M.ms.fd; do
    [[ -f $ovmf/$f ]] || die "$ovmf/$f absent (paquet ovmf)"
done
base=$(sed -n 's/^ANKH_BASE=//p' "$repo/bases.env")
[[ $base == *@sha256:* ]] || die "ANKH_BASE absent de bases.env ou sans digest"
base_ref="${base%%:*}@${base##*@}"
base_digest=${base##*@}
# D-028 : numéro de version d'Ankh, que Discover compare pour proposer une mise à jour.
image_version=$(podman image inspect --format '{{ index .Labels "org.opencontainers.image.version" }}' "$image")
[[ -n $image_version ]] || die "$image n'a pas de label org.opencontainers.image.version"

log "Préparation dans $work"
mkdir -p "$work/captures"
ssh-keygen -q -t ed25519 -N '' -C ankh-vmtest -f "$work/id_ed25519"
rm -f "$work/disk.raw"
truncate -s 40G "$work/disk.raw"
# Variables UEFI avec les clés Microsoft : le shim signé de Fedora démarre
# avec Secure Boot actif, comme sur un vrai PC.
cp "$ovmf/OVMF_VARS_4M.ms.fd" "$work/vars.fd"

log "Installation de $image sur le disque virtuel"
# Méthode officielle : https://github.com/bootc-dev/bootc/blob/main/docs/src/bootc-installation.7.md
# Les arguments du noyau et la clé SSH de root deviennent l'état local de la
# machine : ils restent valables après chaque basculement d'image.
# --target-imgref : le système installé suit le registre d'Ankh pour ses mises
# à jour, comme ma machine installée depuis ce registre (D-027), au lieu du
# stockage local de la CI. Sans cela, Discover cherchait les mises à jour dans
# un registre « localhost » inexistant et affichait « Update Issue » (D-028).
podman run --rm --privileged --pid=host --ipc=host \
    --security-opt label=type:unconfined_t \
    -v /dev:/dev -v /var/lib/containers:/var/lib/containers -v "$work:/output" \
    "$image" \
    bootc install to-disk --generic-image --via-loopback --filesystem btrfs \
    --skip-fetch-check --target-imgref "$other" \
    --root-ssh-authorized-keys /output/id_ed25519.pub \
    --karg console=tty0 --karg console=ttyS0,115200n8 \
    --karg plymouth.ignore-serial-consoles \
    --karg systemd.wants=sshd.service \
    /output/disk.raw

log "Démarrage de la VM (UEFI, Secure Boot)"
qemu-system-x86_64 \
    -name ankh-vmtest \
    -machine q35,smm=on,accel=kvm -cpu host -smp 4 -m 8192 \
    -global driver=cfi.pflash01,property=secure,value=on \
    -drive if=pflash,format=raw,unit=0,readonly=on,file="$ovmf/OVMF_CODE_4M.secboot.fd" \
    -drive if=pflash,format=raw,unit=1,file="$work/vars.fd" \
    -drive if=virtio,format=raw,file="$work/disk.raw" \
    -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:$port-:22" \
    -device virtio-net-pci,netdev=net0 \
    -device virtio-rng-pci \
    -device virtio-vga -display none \
    -device qemu-xhci -device usb-tablet \
    -serial "file:$work/serial.log" \
    -monitor "unix:$work/monitor.sock,server=on,wait=off" \
    -qmp "unix:$work/qmp.sock,server=on,wait=off" &
qemu_pid=$!

log "1/4 Premier démarrage de $image"
# D-034 : l'écran de démarrage, capturé pendant le démarrage. Son moment
# exact dépend de la vitesse de la VM, d'où plusieurs captures.
for n in 1 2 3 4; do
    sleep 5
    screenshot "0-demarrage-$n"
done
wait_boot
check_boot
check_ankh
installed=$(booted imageDigest)
check_installed
screenshot 1-ecran-de-connexion
# D-037 : fond de l'assistant resté uni sur les captures. Fichiers vus dans
# la VM, et messages de l'assistant sur les images (diagnostic seulement).
if ! vm 'ls -laL /usr/share/wallpapers/Next/contents/*/ &&
    journalctl -b --no-pager -o cat _UID="$(id -u plasma-setup)" | grep -iE "png|image|qml|wallpaper|locate" | tail -n 30'; then
    echo "(diagnostic du fond de l'assistant : rien trouvé)"
fi
# Les fichiers sont là et aucune erreur de chargement n'est signalée : l'image
# est cherchée avec StandardPaths.locate (src/qml/LandingComponent.qml de
# plasma-setup), qui dépend des dossiers XDG de l'environnement de
# l'assistant. Cet environnement est affiché (diagnostic seulement).
if ! vm 'pid="$(pgrep -u plasma-setup -x plasma-setup | head -n 1)" &&
    tr "\0" "\n" < "/proc/${pid}/environ" | grep -E "^(XDG_|QT_|HOME=|KDE_|PATH=)"'; then
    echo "(diagnostic du fond de l'assistant : environnement de l'assistant introuvable)"
fi
# D-037 : la page « Bienvenue dans Ankh » de l'assistant, après un clic sur
# « Begin Setup » (au centre de l'écran, vu sur les captures).
click 640 397
sleep 5
screenshot 1-assistant-bienvenue
check_options_assistant

log "Bureau de test : compte « ankhvm » connecté automatiquement, Discover, Chrome et « À propos »"
add_test_account ankhvm 'Compte de test Ankh'
finish_setup
# D-043 : écran de connexion d'Ankh (SDDM), une fois un compte créé (sans
# compte, c'est l'assistant de premier démarrage de KDE qui s'affiche,
# capturé plus haut).
vm systemctl restart display-manager.service
sleep 30
screenshot 1-ecran-de-connexion-compte
configure_autologin
wait_desktop 1-bureau
open_discover 1-discover-mises-a-jour
vm systemd-run --machine=ankhvm@ --user --collect --quiet \
    google-chrome --no-first-run --no-default-browser-check https://github.com/PatrickChoumi/Ankh
sleep 30
screenshot 1-chrome
capture_app 1-vlc vlc
capture_app 1-onlyoffice onlyoffice-desktopeditors
vm systemd-run --machine=ankhvm@ --user --collect --quiet systemsettings kcm_about-distro
sleep 20
screenshot 1-a-propos
# VLC et OnlyOffice, capturés plus haut, resteraient derrière les fenêtres suivantes
close_app ankhvm vlc
close_app ankhvm DesktopEditors
check_vscode
check_options_reglages
check_identity
check_steam
if [[ $gaming_complet == 1 ]]; then
    check_gaming_apps
else
    echo "(premier clic sur les sept autres applications Gaming : seulement avec ANKH_VM_GAMING_COMPLET=1)"
fi
check_console
# D-043 : connexion par l'écran de connexion d'Ankh, avec un mot de passe,
# d'abord faux (message d'erreur), puis juste. La session du compte de test
# est fermée ; la connexion automatique ne se refait qu'au démarrage suivant.
vm "echo 'ankhvm:ankhtest42' | chpasswd"
vm loginctl terminate-user ankhvm
sleep 30
screenshot 1-ecran-de-connexion-ankh
type_text faux
monitor 'sendkey ret'
sleep 8
screenshot 1-ecran-de-connexion-erreur
type_text ankhtest42
monitor 'sendkey ret'
wait_desktop 1-bureau-apres-connexion
check_boot_screen

log "2/4 Mise à jour vers la version publiée : $other"
# Le système suit déjà ce registre (--target-imgref) : c'est une mise à jour,
# pas un basculement (celui-ci est testé à l'étape 4).
vm bootc upgrade
show_boot_state
reboot_vm
check_boot
check_ankh
wait_desktop 2-bureau-ankh-publiee
open_discover 2-discover-mises-a-jour
[[ $(booted image.image) == "$other" ]] || { explain_deployment; die "l'image démarrée n'est pas $other"; }
[[ $(booted imageDigest) != "$installed" ]] || { explain_deployment; die "la mise à jour n'a pas changé de version"; }

log "3/4 Retour arrière (bootc rollback)"
vm bootc rollback
reboot_vm
check_boot
check_ankh
[[ $(booted imageDigest) == "$installed" ]] || { explain_deployment; die "le retour arrière n'a pas redémarré la version installée"; }
check_installed
wait_desktop 3-bureau-apres-retour-arriere

log "4/4 Retour à l'image de base : $base_ref"
vm bootc switch "$base_ref"
show_boot_state
reboot_vm
check_boot
[[ $(booted imageDigest) == "$base_digest" ]] || { explain_deployment; die "l'image démarrée n'est pas la base $base_digest"; }
wait_desktop 4-bureau-image-de-base

log "Réussi : démarrage, mise à jour, retour arrière et retour à la base."
